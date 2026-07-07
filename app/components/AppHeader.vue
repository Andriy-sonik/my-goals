<script setup lang="ts">
const {theme, setTheme} = useTheme()

const listThem: string[] = ['light', 'dark']

const switchColorTheme = (nameTheme: string): void => {
    setTheme(nameTheme)
}

</script>

<template>
    <header class="w-full p-4 bg-slate-300 mb-2 flex gap-2 items-center">
        <NuxtLink to="/">Home</NuxtLink>
        <NuxtLink to="/login">login</NuxtLink>
        <ul class="flex gap-2 ml-auto">
            <li v-for="value in listThem">
                <button 
                    class="bg-orange-200" 
                    :class="[theme === value ? 'bg-red-900' : '']"
                    @click="switchColorTheme(value)">
                    {{ value }}
                </button>
            </li>
        </ul>
    </header>
</template>

<style lang="scss" scoped></style>