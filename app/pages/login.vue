<script setup lang="ts">
const supabase = useSupabaseClient()
const user = useSupabaseUser()
const mode = ref('login')
const email = ref('')
const password = ref('')
const pending = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

watch(user, (value) => {
  if (value) navigateTo('/')
}, { immediate: true })

const submit = async () => {
  pending.value = true
  errorMessage.value = ''
  successMessage.value = ''

  const result = mode.value === 'login'
    ? await supabase.auth.signInWithPassword({ email: email.value, password: password.value })
    : await supabase.auth.signUp({ email: email.value, password: password.value })

  if (result.error) {
    errorMessage.value = result.error.message
  } else if (mode.value === 'signup' && !result.data.session) {
    successMessage.value = 'Перевір пошту, щоб підтвердити акаунт.'
  } else {
    await navigateTo('/')
  }

  pending.value = false
}

const signInWithGoogle = async () => {
  pending.value = true
  errorMessage.value = ''
  const { error } = await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: { redirectTo: `${window.location.origin}/` },
  })
  if (error) errorMessage.value = error.message
  pending.value = false
}
</script>

<template>
  <main class="min-h-[calc(100vh-73px)] bg-slate-950 px-6 py-12 text-slate-100">
    <section class="mx-auto grid max-w-5xl gap-10 lg:grid-cols-[1fr_420px] lg:items-center">
      <div>
        <p class="mb-4 text-sm font-semibold uppercase tracking-[0.25em] text-sky-400">My goals</p>
        <h1 class="max-w-xl text-5xl font-black tracking-tight text-white sm:text-6xl">Час працювати над важливим.</h1>
        <p class="mt-6 max-w-lg text-lg leading-8 text-slate-400">Створюй цілі, запускай таймер і бач свій реальний прогрес щодня.</p>
      </div>

      <form class="rounded-3xl border border-slate-800 bg-slate-900 p-7 shadow-2xl" @submit.prevent="submit">
        <h2 class="text-2xl font-bold text-white">{{ mode === 'login' ? 'З поверненням' : 'Створити акаунт' }}</h2>
        <p class="mt-2 text-sm text-slate-400">{{ mode === 'login' ? 'Увійди, щоб продовжити.' : 'Почни відстежувати свій час.' }}</p>

        <div class="mt-7 space-y-4">
          <label class="block text-sm font-medium text-slate-300">Email<input v-model="email" required type="email" class="mt-2 w-full rounded-xl border border-slate-700 bg-slate-950 px-4 py-3 text-white outline-none transition focus:border-sky-400" /></label>
          <label class="block text-sm font-medium text-slate-300">Пароль<input v-model="password" required minlength="6" type="password" class="mt-2 w-full rounded-xl border border-slate-700 bg-slate-950 px-4 py-3 text-white outline-none transition focus:border-sky-400" /></label>
        </div>

        <p v-if="errorMessage" class="mt-4 rounded-xl bg-rose-950/60 p-3 text-sm text-rose-300">{{ errorMessage }}</p>
        <p v-if="successMessage" class="mt-4 rounded-xl bg-emerald-950/60 p-3 text-sm text-emerald-300">{{ successMessage }}</p>
        <button :disabled="pending" class="mt-6 w-full rounded-xl bg-sky-500 px-4 py-3 font-bold text-slate-950 transition hover:bg-sky-400 disabled:cursor-wait disabled:opacity-60">{{ pending ? 'Зачекай...' : mode === 'login' ? 'Увійти' : 'Зареєструватися' }}</button>
        <button type="button" :disabled="pending" class="mt-3 w-full rounded-xl border border-slate-700 px-4 py-3 font-semibold text-white transition hover:border-slate-500 disabled:opacity-60" @click="signInWithGoogle">Продовжити з Google</button>
        <button type="button" class="mt-5 w-full text-sm text-sky-400 hover:text-sky-300" @click="mode = mode === 'login' ? 'signup' : 'login'">{{ mode === 'login' ? 'Створити новий акаунт' : 'Вже маєш акаунт? Увійти' }}</button>
      </form>
    </section>
  </main>
</template>
