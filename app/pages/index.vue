<script setup lang="ts">
import { useRouter } from 'vue-router'
import type { TGoal } from "~/models" 
const router = useRouter()

    const goals:TGoal[] = [
        {
            id: 0,
            title: 'Goal 1',
            description: 'description Goal 1',
            time: '2026-07-03T11:46:43.851Z',
        },
        {
            id: 1,
            title: 'Goal 2',
            description: 'description Goal 2',
            time: '2026-07-03T11:46:43.851Z',
        }
    ]

    const navigateToGoalDetail = (goalID: number):void => {
         router.push({
            name: 'goals-id',
            params: { id:goalID }
        })
    } 

</script>
<template>
  <div>
    <h1>INDEX</h1>
    <AppItemGoal  
        v-for="goal in goals" 
        :goal="goal" 
        :key="goal.id"
        @click="navigateToGoalDetail(goal.id)"
    />
  </div>
</template>
