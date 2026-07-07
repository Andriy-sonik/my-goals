<script setup lang="ts">
const { theme } = useTheme()

useHead({
  htmlAttrs: {
    'data-theme': theme
  }
})

</script>
<template>
  <div>
    <AppHeader />
    <div class="bg-primary">
      <NuxtLayout>
        <NuxtPage />
      </NuxtLayout>
    </div>
  </div>
</template>
<style lang="scss" scoped>

</style>