<script setup lang="ts">
definePageMeta({ middleware: 'auth' })

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const goals = ref([])
const loading = ref(true)
const saving = ref(false)
const errorMessage = ref('')
const title = ref('')
const description = ref('')
const showForm = ref(false)
const activeTimer = ref()
const totalSeconds = ref(0)

const loadDashboard = async () => {
  if (!user.value) return
  loading.value = true
  const [goalResult, timerResult, entriesResult] = await Promise.all([
    supabase.from('goals').select('*').order('created_at', { ascending: false }),
    supabase.from('time_entries').select('*').is('ended_at', null).maybeSingle(),
    supabase.from('time_entries').select('duration_seconds').not('duration_seconds', 'is', null),
  ])
  if (goalResult.error) errorMessage.value = goalResult.error.message
  goals.value = goalResult.data || []
  activeTimer.value = timerResult.data
  totalSeconds.value = (entriesResult.data || []).reduce((sum, entry) => sum + (entry.duration_seconds || 0), 0)
  loading.value = false
}

const createGoal = async () => {
  if (!title.value.trim()) return
  saving.value = true
  errorMessage.value = ''

  const { data: authData, error: authError } = await supabase.auth.getUser()
  if (authError || !authData.user) {
    errorMessage.value = 'Сесія не знайдена. Увійди в акаунт ще раз.'
    saving.value = false
    return
  }

  const { error } = await supabase.from('goals').insert({
    user_id: authData.user.id,
    title: title.value.trim(),
    description: description.value.trim(),
  })
  if (error) {
    errorMessage.value = error.code === '42501'
      ? 'Supabase не дозволив створити ціль. Перевір, чи виконана SQL-міграція з RLS-політиками для таблиці goals.'
      : error.message
  }
  else {
    title.value = ''
    description.value = ''
    showForm.value = false
    await loadDashboard()
  }
  saving.value = false
}

const toggleGoal = async (goal) => {
  const nextStatus = goal.status === 'completed' ? 'active' : 'completed'
  const { error } = await supabase.from('goals').update({ status: nextStatus, updated_at: new Date().toISOString() }).eq('id', goal.id)
  if (error) errorMessage.value = error.message
  else await loadDashboard()
}

const removeGoal = async (goal) => {
  if (!window.confirm(`Видалити ціль «${goal.title}»?`)) return
  const { error } = await supabase.from('goals').delete().eq('id', goal.id)
  if (error) errorMessage.value = error.message
  else await loadDashboard()
}

const formatTime = (seconds) => {
  const hours = Math.floor(seconds / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)
  return `${hours} год ${minutes} хв`
}

onMounted(loadDashboard)
</script>

<template>
  <main class="min-h-[calc(100vh-73px)] bg-slate-950 px-5 py-8 text-slate-100 sm:px-8">
    <div class="mx-auto max-w-6xl">
      <div class="flex flex-col justify-between gap-5 sm:flex-row sm:items-end">
        <div><p class="text-sm font-semibold uppercase tracking-[0.2em] text-sky-400">Dashboard</p><h1 class="mt-2 text-4xl font-black tracking-tight text-white">Твої цілі</h1><p class="mt-2 text-slate-400">Маленькі сесії складаються у великий прогрес.</p></div>
        <button class="rounded-xl bg-sky-500 px-5 py-3 font-bold text-slate-950 transition hover:bg-sky-400" @click="showForm = !showForm">{{ showForm ? 'Закрити' : '+ Нова ціль' }}</button>
      </div>

      <div class="mt-8 grid gap-4 sm:grid-cols-3"><div class="rounded-2xl border border-slate-800 bg-slate-900 p-5"><p class="text-sm text-slate-400">Всього цілей</p><p class="mt-2 text-3xl font-black text-white">{{ goals.length }}</p></div><div class="rounded-2xl border border-slate-800 bg-slate-900 p-5"><p class="text-sm text-slate-400">Завершено</p><p class="mt-2 text-3xl font-black text-emerald-400">{{ goals.filter(goal => goal.status === 'completed').length }}</p></div><div class="rounded-2xl border border-slate-800 bg-slate-900 p-5"><p class="text-sm text-slate-400">Затрекано часу</p><p class="mt-2 text-3xl font-black text-sky-400">{{ formatTime(totalSeconds) }}</p></div></div>

      <form v-if="showForm" class="mt-8 rounded-2xl border border-sky-900 bg-slate-900 p-6" @submit.prevent="createGoal"><h2 class="text-xl font-bold text-white">Нова ціль</h2><div class="mt-4 grid gap-4 sm:grid-cols-2"><input v-model="title" required maxlength="120" placeholder="Наприклад, вивчити англійську" class="rounded-xl border border-slate-700 bg-slate-950 px-4 py-3 text-white outline-none focus:border-sky-400" /><input v-model="description" placeholder="Короткий опис" class="rounded-xl border border-slate-700 bg-slate-950 px-4 py-3 text-white outline-none focus:border-sky-400" /></div><button :disabled="saving" class="mt-4 rounded-xl bg-white px-5 py-3 font-bold text-slate-950 disabled:opacity-50">{{ saving ? 'Зберігаю...' : 'Створити ціль' }}</button></form>

      <p v-if="errorMessage" class="mt-6 rounded-xl bg-rose-950/60 p-4 text-rose-300">{{ errorMessage }}</p>
      <div v-if="loading" class="py-16 text-center text-slate-400">Завантаження цілей...</div>
      <div v-else-if="!goals.length" class="mt-8 rounded-3xl border border-dashed border-slate-700 px-6 py-16 text-center"><p class="text-xl font-bold text-white">Тут поки порожньо</p><p class="mt-2 text-slate-400">Створи першу ціль і почни відстежувати час.</p></div>
      <div v-else class="mt-8 grid gap-4 md:grid-cols-2"><article v-for="goal in goals" :key="goal.id" class="group rounded-2xl border border-slate-800 bg-slate-900 p-6 transition hover:border-slate-600"><div class="flex items-start justify-between gap-4"><div><p class="text-xs font-semibold uppercase tracking-wider" :class="goal.status === 'completed' ? 'text-emerald-400' : 'text-sky-400'">{{ goal.status === 'completed' ? 'Завершено' : 'В роботі' }}</p><NuxtLink :to="`/goals/${goal.id}`" class="mt-2 block text-xl font-bold text-white hover:text-sky-400">{{ goal.title }}</NuxtLink><p class="mt-2 line-clamp-2 text-sm text-slate-400">{{ goal.description || 'Без опису' }}</p></div><button class="text-slate-500 opacity-0 transition hover:text-rose-400 group-hover:opacity-100" aria-label="Видалити ціль" @click="removeGoal(goal)">Видалити</button></div><div class="mt-6 flex items-center justify-between border-t border-slate-800 pt-4"><button class="text-sm font-semibold text-slate-300 hover:text-white" @click="toggleGoal(goal)">{{ goal.status === 'completed' ? 'Повернути в роботу' : 'Позначити завершеною' }}</button><NuxtLink :to="`/goals/${goal.id}`" class="text-sm font-bold text-sky-400 hover:text-sky-300">Відкрити →</NuxtLink></div></article></div>
    </div>
  </main>
</template>
