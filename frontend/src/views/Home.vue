<template>
  <div class="min-h-screen bg-background">
    <!-- Navigation -->
    <AppNavigation
      @create-task="showCreateModal = true"
    />

    <!-- Main content -->
    <main class="container mx-auto px-4 py-8">
      <!-- Statistics -->
      <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 mb-8">
        <BaseCard class="hover:shadow-lg transition-all duration-200">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <div class="w-12 h-12 bg-primary/10 rounded-xl flex items-center justify-center">
                <ClipboardDocumentListIcon class="h-6 w-6 text-primary" />
              </div>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-muted-foreground">Total des tâches</p>
              <p class="text-2xl font-bold text-foreground">
                {{ tasksStore.loading ? '...' : tasksStore.statistics.total }}
              </p>
            </div>
          </div>
        </BaseCard>

        <BaseCard class="hover:shadow-lg transition-all duration-200">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <div class="w-12 h-12 bg-yellow-500/10 rounded-xl flex items-center justify-center">
                <ClockIcon class="h-6 w-6 text-yellow-500" />
              </div>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-muted-foreground">En attente</p>
              <p class="text-2xl font-bold text-foreground">
                {{ tasksStore.loading ? '...' : tasksStore.statistics.pending }}
              </p>
            </div>
          </div>
        </BaseCard>

        <BaseCard class="hover:shadow-lg transition-all duration-200">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <div class="w-12 h-12 bg-blue-500/10 rounded-xl flex items-center justify-center">
                <BoltIcon class="h-6 w-6 text-blue-500" />
              </div>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-muted-foreground">En cours</p>
              <p class="text-2xl font-bold text-foreground">
                {{ tasksStore.loading ? '...' : tasksStore.statistics.in_progress }}
              </p>
            </div>
          </div>
        </BaseCard>

        <BaseCard class="hover:shadow-lg transition-all duration-200">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <div class="w-12 h-12 bg-green-500/10 rounded-xl flex items-center justify-center">
                <CheckCircleIcon class="h-6 w-6 text-green-500" />
              </div>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-muted-foreground">Terminées</p>
              <p class="text-2xl font-bold text-foreground">
                {{ tasksStore.loading ? '...' : tasksStore.statistics.completed }}
              </p>
            </div>
          </div>
        </BaseCard>

        <BaseCard class="hover:shadow-lg transition-all duration-200">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <div class="w-12 h-12 bg-red-500/10 rounded-xl flex items-center justify-center">
                <XCircleIcon class="h-6 w-6 text-red-500" />
              </div>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-muted-foreground">Annulées</p>
              <p class="text-2xl font-bold text-foreground">
                {{ tasksStore.loading ? '...' : (tasksStore.statistics.canceled || 0) }}
              </p>
            </div>
          </div>
        </BaseCard>
      </div>

      <!-- Recent tasks -->
      <BaseCard>
        <template #header>
          <h3 class="text-lg font-semibold">Tâches récentes</h3>
        </template>
        
        <div v-if="tasksStore.loading" class="flex justify-center py-8">
          <BaseSpinner size="32" />
        </div>
        
        <div v-else-if="tasksStore.tasks.length === 0" class="text-center py-8">
          <div class="mx-auto w-16 h-16 bg-primary/10 rounded-full flex items-center justify-center mb-4">
            <ClipboardDocumentListIcon class="h-8 w-8 text-primary" />
          </div>
          <h3 class="mt-2 text-sm font-medium text-foreground">Aucune tâche</h3>
          <p class="mt-1 text-sm text-muted-foreground">Commencez par créer votre première tâche.</p>
          <div class="mt-6">
            <BaseButton @click="showCreateModal = true" class="flex items-center gap-2">
              <PlusIcon class="h-4 w-4" />
              Créer une tâche
            </BaseButton>
          </div>
        </div>
        
        <div v-else class="space-y-4">
          <div
            v-for="task in tasksStore.tasks.slice(0, 5)"
            :key="task.id"
            class="border border-border rounded-xl p-4 hover:bg-accent/50 transition-all duration-200 cursor-pointer group"
            @click="$router.push(`/tasks/${task.id}`)"
          >
            <div class="flex items-center justify-between">
              <div class="flex-1">
                <div class="flex items-center gap-3 mb-2">
                  <h4 class="text-sm font-medium text-foreground group-hover:text-primary transition-colors">
                    {{ task.title }}
                  </h4>
                  <div class="flex items-center gap-2">
                    <BaseBadge :variant="getStatusVariant(task.status)" size="sm">
                      <template #icon>
                        <ClockIcon v-if="task.status === 'pending'" class="h-3 w-3" />
                        <BoltIcon v-else-if="task.status === 'in_progress'" class="h-3 w-3" />
                        <CheckCircleIcon v-else-if="task.status === 'completed'" class="h-3 w-3" />
                      </template>
                      {{ getStatusLabel(task.status) }}
                    </BaseBadge>
                    <BaseBadge :variant="getPriorityVariant(task.priority)" size="sm">
                      <template #icon>
                        <ExclamationTriangleIcon v-if="task.priority === 'high'" class="h-3 w-3" />
                        <ExclamationCircleIcon v-else-if="task.priority === 'medium'" class="h-3 w-3" />
                        <MinusIcon v-else class="h-3 w-3" />
                      </template>
                      {{ getPriorityLabel(task.priority) }}
                    </BaseBadge>
                  </div>
                </div>
                <p v-if="task.description" class="text-sm text-muted-foreground line-clamp-2">
                  {{ task.description }}
                </p>
                <div v-if="task.due_date" class="flex items-center gap-1 mt-2 text-xs text-muted-foreground">
                  <CalendarIcon class="h-3 w-3" />
                  <span>Échéance: {{ formatDate(task.due_date) }}</span>
                </div>
              </div>
              <div class="flex items-center space-x-2 ml-4">
                <BaseButton
                  variant="ghost"
                  size="sm"
                  class="h-8 w-8 p-0 opacity-0 group-hover:opacity-100 transition-opacity"
                  @click.stop="$router.push(`/tasks/${task.id}`)"
                >
                  <EyeIcon class="h-4 w-4" />
                </BaseButton>
              </div>
            </div>
          </div>
          
          <div class="text-center pt-4">
            <BaseButton
              variant="outline"
              @click="$router.push('/tasks')"
              class="flex items-center gap-2 mx-auto"
            >
              <ArrowRightIcon class="h-4 w-4" />
              Voir toutes les tâches
            </BaseButton>
          </div>
        </div>
      </BaseCard>
    </main>

    <!-- Create Task Modal -->
    <BaseModal
      v-model="showCreateModal"
      title="Nouvelle tâche"
      size="lg"
    >
      <TaskForm
        :loading="formLoading"
        @submit="handleFormSubmit"
        @cancel="showCreateModal = false"
      />
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useTasksStore } from '@/stores/tasks'
import { useNotificationsStore } from '@/stores/notifications'
import {
  BaseCard,
  BaseButton,
  BaseBadge,
  BaseSpinner,
  BaseModal,
  AppNavigation
} from '@/components'
import TaskForm from '@/components/organisms/TaskForm.vue'
import { 
  ClipboardDocumentListIcon, 
  ClockIcon, 
  BoltIcon, 
  CheckCircleIcon, 
  ExclamationTriangleIcon, 
  ExclamationCircleIcon, 
  MinusIcon, 
  CalendarIcon, 
  ArrowRightIcon, 
  EyeIcon, 
  PlusIcon, 
  XCircleIcon 
} from '@heroicons/vue/24/outline'

const router = useRouter()
const authStore = useAuthStore()
const tasksStore = useTasksStore()
const notificationsStore = useNotificationsStore()

const showCreateModal = ref(false)
const formLoading = ref(false)

onMounted(async () => {
  await tasksStore.fetchTasks()
  await tasksStore.fetchStatistics()
})

const handleFormSubmit = async (taskData) => {
  formLoading.value = true
  try {
    const result = await tasksStore.createTask(taskData)
    if (result.success) {
      showCreateModal.value = false
      await tasksStore.fetchTasks()
      await tasksStore.fetchStatistics()
      // Refresh notification count in case a new notification was created
      await notificationsStore.forceRefreshCount()
    }
  } finally {
    formLoading.value = false
  }
}

const getStatusLabel = (status) => {
  const labels = {
    pending: 'En attente',
    in_progress: 'En cours',
    completed: 'Terminée'
  }
  return labels[status] || status
}

const getPriorityLabel = (priority) => {
  const labels = {
    low: 'Faible',
    medium: 'Moyenne',
    high: 'Élevée'
  }
  return labels[priority] || priority
}

const getStatusVariant = (status) => {
  const variants = {
    pending: 'secondary',
    in_progress: 'default',
    completed: 'outline'
  }
  return variants[status] || 'secondary'
}

const getPriorityVariant = (priority) => {
  const variants = {
    low: 'secondary',
    medium: 'default',
    high: 'destructive'
  }
  return variants[priority] || 'secondary'
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString()
}
</script> 