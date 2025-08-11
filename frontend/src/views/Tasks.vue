<template>
  <div class="min-h-screen bg-background">
    <!-- Navigation -->
    <AppNavigation
      :notification-count="0"
      @create-task="showCreateModal = true"
    />

    <!-- Main content -->
    <div class="container mx-auto px-4 py-8">
      <!-- Toggle entre vue liste et kanban -->
      <div class="flex items-center justify-between mb-6">
        <div class="flex items-center gap-2">
          <BaseButton
            :variant="viewMode === 'list' ? 'default' : 'outline'"
            size="sm"
            @click="viewMode = 'list'"
          >
            <ListBulletIcon class="w-4 h-4 mr-2" />
            Liste
          </BaseButton>
          <BaseButton
            :variant="viewMode === 'kanban' ? 'default' : 'outline'"
            size="sm"
            @click="viewMode = 'kanban'"
          >
            <Squares2X2Icon class="w-4 h-4 mr-2" />
            Kanban
          </BaseButton>
        </div>
      </div>

      <!-- Vue Liste -->
      <div v-if="viewMode === 'list'">
        <TaskList
          :tasks="tasks"
          :loading="loading"
          :current-page="currentPage"
          :total-pages="totalPages"
          @create="showCreateModal = true"
          @view="viewTask"
          @edit="editTask"
          @delete="deleteTask"
          @page-change="handlePageChange"
        />
      </div>

      <!-- Vue Kanban -->
      <div v-else>
        <KanbanBoard
          :tasks="tasks"
          :loading="loading"
          @create="showCreateModal = true"
          @view="viewTask"
          @edit="editTask"
          @delete="deleteTask"
          @status-change="handleStatusChange"
        />
      </div>
      
      <!-- Create/Edit Modal -->
      <BaseModal
        v-model="isModalOpen"
        :title="showEditModal ? 'Modifier la tâche' : 'Nouvelle tâche'"
        size="lg"
      >
        <TaskForm
          :task="editingTask"
          :loading="formLoading"
          @submit="handleFormSubmit"
          @cancel="closeModal"
        />
      </BaseModal>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useToast } from 'vue-toastification'
import { ListBulletIcon, Squares2X2Icon } from '@heroicons/vue/24/outline'
import api from '@/services/api'
import BaseModal from '@/components/atoms/BaseModal.vue'
import TaskList from '@/components/organisms/TaskList.vue'
import TaskForm from '@/components/organisms/TaskForm.vue'
import AppNavigation from '@/components/organisms/AppNavigation.vue'
import KanbanBoard from '@/components/organisms/KanbanBoard.vue'
import { BaseButton } from '@/components'

const router = useRouter()
const toast = useToast()

const tasks = ref([])
const loading = ref(false)
const formLoading = ref(false)
const currentPage = ref(1)
const totalPages = ref(1)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const editingTask = ref(null)
const viewMode = ref('kanban') // Par défaut en mode kanban

const isModalOpen = computed({
  get: () => showCreateModal.value || showEditModal.value,
  set: (value) => {
    if (!value) {
      closeModal()
    }
  }
})

const fetchTasks = async (page = 1) => {
  loading.value = true
  try {
    const response = await api.get(`/tasks?page=${page}`)
    tasks.value = response.data.data
    currentPage.value = response.data.current_page
    totalPages.value = response.data.last_page
  } catch (error) {
    toast.error('Erreur lors du chargement des tâches')
  } finally {
    loading.value = false
  }
}

const handlePageChange = (page) => {
  fetchTasks(page)
}

const viewTask = (task) => {
  router.push(`/tasks/${task.id}`)
}

const editTask = (task) => {
  editingTask.value = task
  showEditModal.value = true
}

const deleteTask = async (task) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer cette tâche ?')) {
    try {
      await api.delete(`/tasks/${task.id}`)
      toast.success('Tâche supprimée avec succès')
      fetchTasks(currentPage.value)
    } catch (error) {
      toast.error('Erreur lors de la suppression')
    }
  }
}

const handleStatusChange = async ({ task, newStatus }) => {
  try {
    await api.put(`/tasks/${task.id}`, { ...task, status: newStatus })
    toast.success(`Tâche déplacée vers ${getStatusLabel(newStatus)}`)
    fetchTasks(currentPage.value)
  } catch (error) {
    toast.error('Erreur lors du changement de statut')
  }
}

const getStatusLabel = (status) => {
  const labels = {
    pending: 'À faire',
    in_progress: 'En cours',
    completed: 'Terminé',
    canceled: 'Annulé'
  }
  return labels[status] || status
}

const handleFormSubmit = async (taskData) => {
  formLoading.value = true
  try {
    if (showEditModal.value) {
      await api.put(`/tasks/${editingTask.value.id}`, taskData)
      toast.success('Tâche mise à jour avec succès')
    } else {
      await api.post('/tasks', taskData)
      toast.success('Tâche créée avec succès')
    }
    closeModal()
    fetchTasks(currentPage.value)
  } catch (error) {
    const message = error.response?.data?.message || 'Erreur lors de l\'opération'
    toast.error(message)
  } finally {
    formLoading.value = false
  }
}

const closeModal = () => {
  showCreateModal.value = false
  showEditModal.value = false
  editingTask.value = null
}

onMounted(() => {
  fetchTasks()
})
</script> 