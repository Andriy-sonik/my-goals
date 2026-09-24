<template>
  <svg
      :width="size"
      :height="size"
      class="icon"
      :role="label ? 'img' : 'presentation'"
      :aria-hidden="label ? undefined : true"
      :aria-label="label"
    >
      <use :href="`/sprite.svg#${name}`" />
    </svg>
  </template>
  <script setup lang="ts">
  defineProps<{
    name: string
    size?: number
    label?: string
  }>()  
  </script>