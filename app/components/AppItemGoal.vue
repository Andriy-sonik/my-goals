<script setup lang="ts">
   import type { TGoal } from "~/models" 

    const props = defineProps<{
        goal: TGoal
    }>()

</script>
<template>
  <div>
    AppItemGoal {{ props.goal }}
  </div>
</template>
