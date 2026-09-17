<script setup lang="ts">
const {theme, setTheme} = useTheme()
const supabase = useSupabaseClient()
const user = useSupabaseUser()

const listThem: string[] = ['light', 'dark']

const switchColorTheme = (nameTheme: string): void => {
    setTheme(nameTheme)
}

const signOut = async () => {
    await supabase.auth.signOut()
    await navigateTo('/login')
}

</script>

<template>
    <header class="flex w-full items-center gap-4 border-b border-slate-800 bg-slate-950 px-5 py-4 text-slate-100 sm:px-8">
        <NuxtLink to="/" class="text-lg font-black tracking-tight text-white">My goals<span class="text-sky-400">.</span></NuxtLink>
        <nav v-if="user" class="flex gap-4 text-sm text-slate-400">
            <NuxtLink to="/" class="transition hover:text-white">Цілі</NuxtLink>
        </nav>
        <div class="ml-auto flex items-center gap-3">
            <span v-if="user" class="hidden text-sm text-slate-400 sm:inline">{{ user.email }}</span>
            <button v-if="user" class="text-sm font-semibold text-slate-300 hover:text-white" @click="signOut">Вийти</button>
            <NuxtLink v-else to="/login" class="text-sm font-semibold text-sky-400 hover:text-sky-300">Увійти</NuxtLink>
        </div>
        <ul class="flex gap-2">
            <li v-for="value in listThem">
                <button 
                    class="rounded-lg px-2 py-1 text-xs uppercase text-slate-400 transition hover:text-white" 
                    :class="[theme === value ? 'bg-slate-800 text-white' : '']"
                    @click="switchColorTheme(value)">
                    {{ value }}
                </button>
            </li>
        </ul>
    </header>
</template>