<script setup lang="ts">
definePageMeta({ middleware: 'auth' })

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const route = useRoute()
const goal = ref()
const comments = ref([])
const entries = ref([])
const commentBody = ref('')
const editingComment = ref()
const activeEntry = ref()
const loading = ref(true)
const pending = ref(false)
const errorMessage = ref('')
const now = ref(Date.now())
let ticker

const loadGoal = async () => {
  const [goalResult, commentsResult, entriesResult, activeResult] = await Promise.all([
    supabase.from('goals').select('*').eq('id', route.params.id).single(),
    supabase.from('comments').select('*').eq('goal_id', route.params.id).order('created_at', { ascending: false }),
    supabase.from('time_entries').select('*').eq('goal_id', route.params.id).not('duration_seconds', 'is', null).order('started_at', { ascending: false }),
    supabase.from('time_entries').select('*').eq('goal_id', route.params.id).is('ended_at', null).maybeSingle(),
  ])
  if (goalResult.error) errorMessage.value = goalResult.error.message
  goal.value = goalResult.data
  comments.value = commentsResult.data || []
  entries.value = entriesResult.data || []
  activeEntry.value = activeResult.data
  loading.value = false
}

const addComment = async () => {
  if (!commentBody.value.trim()) return
  pending.value = true
  const { data: authData, error: authError } = await supabase.auth.getUser()
  if (authError || !authData.user) {
    errorMessage.value = 'Сесія не знайдена. Увійди в акаунт ще раз.'
    pending.value = false
    return
  }

  const payload = { body: commentBody.value.trim(), goal_id: route.params.id, user_id: authData.user.id }
  const result = editingComment.value
    ? await supabase.from('comments').update({ body: payload.body, updated_at: new Date().toISOString() }).eq('id', editingComment.value)
    : await supabase.from('comments').insert(payload)
  if (result.error) {
    errorMessage.value = result.error.code === '42501'
      ? 'Supabase не дозволив додати коментар. Виконай SQL-міграцію 002_fix_rls_policies.sql у Supabase SQL Editor.'
      : result.error.message
  }
  else { commentBody.value = ''; editingComment.value = undefined; await loadGoal() }
  pending.value = false
}

const deleteComment = async (comment) => {
  const { error } = await supabase.from('comments').delete().eq('id', comment.id)
  if (error) errorMessage.value = error.message
  else await loadGoal()
}

const startTimer = async () => {
  if (activeEntry.value) return
  errorMessage.value = ''

  const { data: authData, error: authError } = await supabase.auth.getUser()
  if (authError || !authData.user) {
    errorMessage.value = 'Сесія не знайдена. Увійди в акаунт ще раз.'
    return
  }

  const { data, error } = await supabase.from('time_entries').insert({
    user_id: authData.user.id,
    goal_id: route.params.id,
  }).select().single()

  if (error) {
    errorMessage.value = error.code === '42501'
      ? 'Supabase не дозволив запустити таймер. Виконай SQL-міграцію 002_fix_rls_policies.sql у Supabase SQL Editor.'
      : error.message
  }
  else { activeEntry.value = data; startTicker() }
}

const stopTimer = async () => {
  if (!activeEntry.value) return
  const duration = Math.max(0, Math.floor((Date.now() - new Date(activeEntry.value.started_at).getTime()) / 1000))
  const { error } = await supabase.from('time_entries').update({ ended_at: new Date().toISOString(), duration_seconds: duration }).eq('id', activeEntry.value.id)
  if (error) errorMessage.value = error.message
  else { activeEntry.value = undefined; clearInterval(ticker); await loadGoal() }
}

const elapsed = () => activeEntry.value ? Math.max(0, Math.floor((now.value - new Date(activeEntry.value.started_at).getTime()) / 1000)) : 0
const totalTime = () => entries.value.reduce((sum, entry) => sum + (entry.duration_seconds || 0), 0) + elapsed()
const formatTime = (seconds) => `${Math.floor(seconds / 3600)} год ${Math.floor((seconds % 3600) / 60)} хв`
const startTicker = () => { clearInterval(ticker); ticker = window.setInterval(() => { now.value = Date.now() }, 1000) }

onMounted(async () => { await loadGoal(); if (activeEntry.value) startTicker() })
onBeforeUnmount(() => clearInterval(ticker))
</script>

<template>
  <main class="min-h-[calc(100vh-73px)] bg-slate-950 px-5 py-8 text-slate-100 sm:px-8">
    <div class="mx-auto max-w-5xl">
      <NuxtLink to="/" class="text-sm font-semibold text-sky-400 hover:text-sky-300">← До всіх цілей</NuxtLink>
      <div v-if="loading" class="py-20 text-center text-slate-400">Завантаження...</div>
      <p v-else-if="errorMessage" class="mt-8 rounded-xl bg-rose-950/60 p-4 text-rose-300">{{ errorMessage }}</p>
      <template v-else-if="goal">
        <header class="mt-8 flex flex-col justify-between gap-6 border-b border-slate-800 pb-8 sm:flex-row sm:items-end"><div><p class="text-sm font-semibold uppercase tracking-[0.2em] text-sky-400">{{ goal.status === 'completed' ? 'Завершено' : 'В роботі' }}</p><h1 class="mt-2 text-4xl font-black tracking-tight text-white">{{ goal.title }}</h1><p class="mt-3 max-w-2xl text-slate-400">{{ goal.description || 'Без опису' }}</p></div><div class="text-left sm:text-right"><p class="text-sm text-slate-400">Загальний час</p><p class="mt-1 text-3xl font-black text-sky-400">{{ formatTime(totalTime()) }}</p></div></header>
        <section class="mt-8 rounded-3xl border border-slate-800 bg-slate-900 p-6"><div class="flex flex-col justify-between gap-5 sm:flex-row sm:items-center"><div><p class="text-sm font-semibold uppercase tracking-wider text-slate-400">Фокус-сесія</p><p class="mt-2 text-2xl font-bold text-white">{{ activeEntry ? formatTime(elapsed()) : 'Готовий почати?' }}</p></div><button v-if="!activeEntry" class="rounded-xl bg-emerald-400 px-6 py-3 font-bold text-slate-950 hover:bg-emerald-300" @click="startTimer">Запустити таймер</button><button v-else class="rounded-xl bg-rose-400 px-6 py-3 font-bold text-slate-950 hover:bg-rose-300" @click="stopTimer">Зупинити таймер</button></div></section>
        <section class="mt-8 grid gap-8 lg:grid-cols-[1fr_340px]"><div><div class="flex items-center justify-between"><h2 class="text-xl font-bold text-white">Коментарі</h2><span class="text-sm text-slate-500">{{ comments.length }}</span></div><form class="mt-4" @submit.prevent="addComment"><textarea v-model="commentBody" rows="3" maxlength="2000" placeholder="Запиши думку або результат сесії..." class="w-full resize-none rounded-2xl border border-slate-800 bg-slate-900 p-4 text-white outline-none focus:border-sky-400"></textarea><div class="mt-3 flex justify-end gap-3"><button v-if="editingComment" type="button" class="px-4 py-2 text-sm text-slate-400" @click="editingComment = undefined; commentBody = ''">Скасувати</button><button :disabled="pending || !commentBody.trim()" class="rounded-xl bg-white px-4 py-2 text-sm font-bold text-slate-950 disabled:opacity-50">{{ editingComment ? 'Зберегти' : 'Додати коментар' }}</button></div></form><div class="mt-6 space-y-3"><article v-for="comment in comments" :key="comment.id" class="rounded-2xl border border-slate-800 bg-slate-900 p-5"><p class="whitespace-pre-wrap text-slate-200">{{ comment.body }}</p><div class="mt-4 flex items-center justify-between text-xs text-slate-500"><time>{{ new Date(comment.created_at).toLocaleString('uk-UA') }}</time><div class="flex gap-3"><button class="hover:text-white" @click="editingComment = comment.id; commentBody = comment.body">Редагувати</button><button class="hover:text-rose-400" @click="deleteComment(comment)">Видалити</button></div></div></article><p v-if="!comments.length" class="py-8 text-center text-slate-500">Коментарів ще немає.</p></div></div><aside class="rounded-2xl border border-slate-800 bg-slate-900 p-6"><h2 class="text-xl font-bold text-white">Останні сесії</h2><div class="mt-5 space-y-4"><div v-for="entry in entries.slice(0, 5)" :key="entry.id" class="flex justify-between gap-4 text-sm"><time class="text-slate-400">{{ new Date(entry.started_at).toLocaleDateString('uk-UA') }}</time><span class="font-semibold text-white">{{ formatTime(entry.duration_seconds) }}</span></div><p v-if="!entries.length" class="text-sm text-slate-500">Сесій ще немає.</p></div></aside></section>
      </template>
    </div>
  </main>
</template>