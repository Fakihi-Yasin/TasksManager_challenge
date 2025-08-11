<template>
  <div class="min-h-screen bg-background">
    <AppNavigation
      @create-task="showCreateModal = true"
    />

    <main class="container mx-auto px-4 py-8">
      <div class="flex items-center justify-between mb-8">
        <div>
          <h1 class="text-3xl font-bold text-foreground">Notifications</h1>
          <p class="text-muted-foreground mt-2">
            Gérez vos notifications et restez informé de vos tâches
          </p>
        </div>
        <div class="flex gap-2">
          <BaseButton
            variant="outline"
            @click="markAllAsRead"
            :disabled="!notificationsStore.hasUnreadNotifications"
          >
            Tout marquer comme lu
          </BaseButton>
          <BaseButton
            variant="destructive"
            @click="clearAllNotifications"
            :disabled="notificationsStore.notifications.length === 0"
          >
            Tout effacer
          </BaseButton>
        </div>
      </div>

      <div v-if="notificationsStore.loading" class="flex justify-center py-12">
        <BaseSpinner size="32" />
      </div>

      <div v-else-if="notificationsStore.notifications.length === 0" class="text-center py-12">
        <div class="mx-auto h-24 w-24 text-muted-foreground mb-4">
          <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-5 5v-5zM4.19 4.19A4 4 0 004 6v10a4 4 0 004 4h10a4 4 0 004-4V6a4 4 0 00-4-4H8a4 4 0 00-2.83 1.17z" />
          </svg>
        </div>
        <h3 class="text-lg font-medium text-foreground mb-2">Aucune notification</h3>
        <p class="text-muted-foreground">
          Vous n'avez pas encore de notifications. Elles apparaîtront ici.
        </p>
      </div>

      <div v-else class="space-y-4">
        <BaseCard
          v-for="notification in notificationsStore.notifications"
          :key="notification.id"
          class="transition-all duration-200 hover:shadow-md"
          :class="{ 'bg-accent/50': !notification.read_at }"
        >
          <div class="flex items-start justify-between p-4">
            <div class="flex items-start space-x-3 flex-1">
              <div class="flex-shrink-0 mt-1">
                <div
                  class="w-2 h-2 rounded-full"
                  :class="{
                    'bg-blue-500': notification.type === 'task_created',
                    'bg-green-500': notification.type === 'task_completed',
                    'bg-yellow-500': notification.type === 'task_updated',
                    'bg-red-500': notification.type === 'task_deleted'
                  }"
                ></div>
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-medium text-foreground">
                  {{ getNotificationTitle(notification) }}
                </p>
                <p class="text-sm text-muted-foreground mt-1">
                  {{ notification.data.message || notification.data.description }}
                </p>
                <div class="flex items-center mt-2 space-x-4">
                  <span class="text-xs text-muted-foreground">
                    {{ formatDate(notification.created_at) }}
                  </span>
                  <BaseBadge
                    v-if="!notification.read_at"
                    variant="secondary"
                    size="sm"
                  >
                    Nouveau
                  </BaseBadge>
                </div>
              </div>
            </div>
            <div class="flex items-center space-x-2 ml-4">
              <BaseButton
                v-if="!notification.read_at"
                variant="ghost"
                size="sm"
                @click="markAsRead(notification.id)"
              >
                Marquer comme lu
              </BaseButton>
              <BaseButton
                variant="ghost"
                size="sm"
                @click="deleteNotification(notification.id)"
              >
                Supprimer
              </BaseButton>
            </div>
          </div>
        </BaseCard>
      </div>

      <!-- Pagination -->
      <div v-if="notificationsStore.totalPages > 1" class="flex justify-center mt-8">
        <div class="flex items-center space-x-2">
          <BaseButton
            variant="outline"
            size="sm"
            :disabled="notificationsStore.currentPage === 1"
            @click="changePage(notificationsStore.currentPage - 1)"
          >
            Précédent
          </BaseButton>
          <span class="text-sm text-muted-foreground">
            Page {{ notificationsStore.currentPage }} sur {{ notificationsStore.totalPages }}
          </span>
          <BaseButton
            variant="outline"
            size="sm"
            :disabled="notificationsStore.currentPage === notificationsStore.totalPages"
            @click="changePage(notificationsStore.currentPage + 1)"
          >
            Suivant
          </BaseButton>
        </div>
      </div>
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
import { useToast } from 'vue-toastification'
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

const toast = useToast()
const tasksStore = useTasksStore()
const notificationsStore = useNotificationsStore()

const showCreateModal = ref(false)
const formLoading = ref(false)

const markAsRead = async (id) => {
  await notificationsStore.markAsRead(id)
  // Force immediate count update
  await notificationsStore.forceRefreshCount()
}

const markAllAsRead = async () => {
  await notificationsStore.markAllAsRead()
  // Force immediate count update
  await notificationsStore.forceRefreshCount()
}

const deleteNotification = async (id) => {
  await notificationsStore.deleteNotification(id)
  // Force immediate count update
  await notificationsStore.forceRefreshCount()
}

const clearAllNotifications = async () => {
  await notificationsStore.clearAllNotifications()
  // Force immediate count update
  await notificationsStore.forceRefreshCount()
}

const changePage = (page) => {
  notificationsStore.fetchNotifications(page)
}

const getNotificationTitle = (notification) => {
  const titles = {
    task_created: 'Nouvelle tâche créée',
    task_updated: 'Tâche mise à jour',
    task_completed: 'Tâche terminée',
    task_deleted: 'Tâche supprimée'
  }
  return titles[notification.type] || 'Notification'
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  const now = new Date()
  const diffInHours = (now - date) / (1000 * 60 * 60)
  
  if (diffInHours < 1) {
    return 'Il y a quelques minutes'
  } else if (diffInHours < 24) {
    return `Il y a ${Math.floor(diffInHours)} heure${Math.floor(diffInHours) > 1 ? 's' : ''}`
  } else {
    return date.toLocaleDateString('fr-FR', {
      day: 'numeric',
      month: 'long',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }
}

const handleFormSubmit = async (taskData) => {
  formLoading.value = true
  try {
    const result = await tasksStore.createTask(taskData)
    if (result.success) {
      showCreateModal.value = false
      // Refresh notifications to include the new task
      await notificationsStore.fetchNotifications()
      // Force refresh count to ensure accuracy
      await notificationsStore.forceRefreshCount()
    }
  } finally {
    formLoading.value = false
  }
}

onMounted(() => {
  notificationsStore.fetchNotifications()
})
</script>