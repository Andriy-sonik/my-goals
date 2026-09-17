// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  modules: [
    '@pinia/nuxt',
    '@nuxtjs/tailwindcss',
    '@nuxtjs/supabase',
  ],
  css: [
    '~/assets/generated/themes.css',
  ],
  supabase: {
    redirect: false,
  },
})