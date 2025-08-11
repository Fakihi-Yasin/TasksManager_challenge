<template>
  <div class="min-h-screen bg-background">
    <AppNavigation
      @create-task="showCreateModal = true"
    />

    <main class="container mx-auto px-4 py-8">
      <div v-if="loading" class="flex justify-center py-12">
        <BaseSpinner size="32" />
      </div>

      <div v-else-if="!task" class="text-center py-12">
        <div class="mx-auto h-24 w-24 text-muted-foreground mb-4">
          <DocumentIcon class="h-full w-full" />
        </div>
        <h3 class="text-lg font-medium text-foreground mb-2">Tâche non trouvée</h3>
        <p class="text-muted-foreground mb-4">
          La tâche que vous recherchez n'existe pas ou a été supprimée.
        </p>
        <BaseButton @click="$router.push('/tasks')">
          Retour aux tâches
        </BaseButton>
      </div>

      <div v-else class="space-y-6">
        <!-- Header -->
        <div class="flex items-start justify-between">
          <div class="flex-1">
            <div class="flex items-center space-x-3 mb-2">
              <BaseButton
                variant="ghost"
                size="sm"
                @click="$router.push('/tasks')"
              >
                <ArrowLeftIcon class="h-4 w-4 mr-2" />
                Retour
              </BaseButton>
            </div>
            <h1 class="text-3xl font-bold text-foreground">{{ task.title }}</h1>
            <div class="flex items-center space-x-2 mt-2">
              <BaseBadge :variant="getStatusVariant(task.status)">
                {{ getStatusLabel(task.status) }}
              </BaseBadge>
              <BaseBadge :variant="getPriorityVariant(task.priority)">
                {{ getPriorityLabel(task.priority) }}
              </BaseBadge>
            </div>
          </div>
          <div class="flex items-center space-x-2">
            <BaseButton
              variant="outline"
              @click="editTask"
            >
              <PencilIcon class="h-4 w-4 mr-2" />
              Modifier
            </BaseButton>
            <BaseButton
              variant="destructive"
              @click="deleteTask"
            >
              <TrashIcon class="h-4 w-4 mr-2" />
              Supprimer
            </BaseButton>
          </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <!-- Main content -->
          <div class="lg:col-span-2 space-y-6">
            <!-- Description -->
            <BaseCard>
              <template #header>
                <h3 class="text-lg font-semibold">Description</h3>
              </template>
              <div class="prose prose-sm max-w-none">
                <p v-if="task.description" class="text-foreground">
                  {{ task.description }}
                </p>
                <p v-else class="text-muted-foreground italic">
                  Aucune description fournie
                </p>
              </div>
            </BaseCard>

            <!-- Comments section -->
            <BaseCard>
              <template #header>
                <h3 class="text-lg font-semibold">Commentaires</h3>
              </template>
              <div class="space-y-4">
                <div v-if="comments.length === 0" class="text-center py-8">
                  <ChatBubbleLeftRightIcon class="h-12 w-12 text-muted-foreground mx-auto mb-2" />
                  <p class="text-muted-foreground">Aucun commentaire pour le moment</p>
                </div>
                <div v-else class="space-y-4">
                  <div
                    v-for="comment in comments"
                    :key="comment.id"
                    class="border-l-4 border-primary/20 pl-4 py-2"
                  >
                    <div class="flex items-start justify-between">
                      <div class="flex-1">
                        <p class="text-sm font-medium text-foreground">
                          {{ comment.user?.full_name || 'Utilisateur' }}
                        </p>
                        <p class="text-sm text-muted-foreground mt-1">
                          {{ comment.content }}
                        </p>
                        <p class="text-xs text-muted-foreground mt-2">
                          {{ formatDate(comment.created_at) }}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
                
                <!-- Add comment form -->
                <div class="border-t pt-4">
                  <div class="space-y-2">
                    <textarea
                      v-model="newComment"
                      rows="3"
                      placeholder="Ajouter un commentaire..."
                      class="flex w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                    ></textarea>
                    <div class="flex justify-end">
                      <BaseButton
                        @click="addComment"
                        :disabled="!newComment.trim()"
                        size="sm"
                      >
                        <PaperAirplaneIcon class="h-4 w-4 mr-2" />
                        Ajouter un commentaire
                      </BaseButton>
                    </div>
                  </div>
                </div>
              </div>
            </BaseCard>
          </div>

          <!-- Sidebar -->
          <div class="space-y-6">
            <!-- Task details -->
            <BaseCard>
              <template #header>
                <h3 class="text-lg font-semibold">Détails</h3>
              </template>
              <div class="space-y-4">
                <div>
                  <label class="text-sm font-medium text-muted-foreground">Statut</label>
                  <div class="mt-1">
                    <BaseBadge :variant="getStatusVariant(task.status)">
                      {{ getStatusLabel(task.status) }}
                    </BaseBadge>
                  </div>
                </div>
                
                <div>
                  <label class="text-sm font-medium text-muted-foreground">Priorité</label>
                  <div class="mt-1">
                    <BaseBadge :variant="getPriorityVariant(task.priority)">
                      {{ getPriorityLabel(task.priority) }}
                    </BaseBadge>
                  </div>
                </div>
                
                <div>
                  <label class="text-sm font-medium text-muted-foreground">Date de création</label>
                  <p class="text-sm text-foreground mt-1">
                    {{ formatDate(task.created_at) }}
                  </p>
                </div>
                
                <div v-if="task.due_date">
                  <label class="text-sm font-medium text-muted-foreground">Date d'échéance</label>
                  <p class="text-sm text-foreground mt-1">
                    {{ formatDate(task.due_date) }}
                  </p>
                </div>
                
                <div v-if="task.updated_at">
                  <label class="text-sm font-medium text-muted-foreground">Dernière modification</label>
                  <p class="text-sm text-foreground mt-1">
                    {{ formatDate(task.updated_at) }}
                  </p>
                </div>
              </div>
            </BaseCard>

            <!-- Actions -->
            <BaseCard>
              <template #header>
                <h3 class="text-lg font-semibold">Actions</h3>
              </template>
              <div class="space-y-2">
                <BaseButton
                  v-if="task.status !== 'completed'"
                  @click="updateStatus('completed')"
                  variant="outline"
                  class="w-full justify-start"
                >
                  <CheckIcon class="h-4 w-4 mr-2" />
                  Marquer comme terminée
                </BaseButton>
                
                <BaseButton
                  v-if="task.status === 'pending'"
                  @click="updateStatus('in_progress')"
                  variant="outline"
                  class="w-full justify-start"
                >
                  <PlayIcon class="h-4 w-4 mr-2" />
                  Commencer
                </BaseButton>
                
                <BaseButton
                  v-if="task.status === 'in_progress'"
                  @click="updateStatus('pending')"
                  variant="outline"
                  class="w-full justify-start"
                >
                  <PauseIcon class="h-4 w-4 mr-2" />
                  Mettre en pause
                </BaseButton>

                <BaseButton
                  v-if="task.status !== 'canceled'"
                  @click="updateStatus('canceled')"
                  variant="outline"
                  class="w-full justify-start"
                >
                  <XMarkIcon class="h-4 w-4 mr-2" />
                  Annuler la tâche
                </BaseButton>

                <BaseButton
                  v-if="task.status === 'canceled'"
                  @click="updateStatus('pending')"
                  variant="outline"
                  class="w-full justify-start"
                >
                  <ArrowPathIcon class="h-4 w-4 mr-2" />
                  Réactiver
                </BaseButton>
              </div>
            </BaseCard>
          </div>
        </div>
      </div>

      <!-- Edit Modal -->
      <BaseModal
        v-model="showEditModal"
        title="Modifier la tâche"
        size="lg"
      >
        <TaskForm
          :task="task"
          :loading="formLoading"
          @submit="handleFormSubmit"
          @cancel="showEditModal = false"
        />
      </BaseModal>

      <!-- Create Task Modal -->
      <BaseModal
        v-model="showCreateModal"
        title="Nouvelle tâche"
        size="lg"
      >
        <TaskForm
          :loading="createFormLoading"
          @submit="handleCreateFormSubmit"
          @cancel="showCreateModal = false"
        />
      </BaseModal>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useToast } from 'vue-toastification'
import { useTasksStore } from '@/stores/tasks'
import { useNotificationsStore } from '@/stores/notifications'
import { 
  ArrowLeftIcon,
  PencilIcon,
  TrashIcon,
  DocumentIcon,
  ChatBubbleLeftRightIcon,
  PaperAirplaneIcon,
  CheckIcon,
  PlayIcon,
  PauseIcon,
  XMarkIcon,
  ArrowPathIcon
} from '@heroicons/vue/24/outline'
import api from '@/services/api'
import {
  BaseCard,
  BaseButton,
  BaseBadge,
  BaseSpinner,
  BaseModal,
  AppNavigation,
  TaskForm
} from '@/components'

const route = useRoute()
const router = useRouter()
const toast = useToast()
const tasksStore = useTasksStore()
const notificationsStore = useNotificationsStore()

const task = ref(null)
const comments = ref([])
const loading = ref(false)
const formLoading = ref(false)
const createFormLoading = ref(false)
const showEditModal = ref(false)
const showCreateModal = ref(false)
const newComment = ref('')

const fetchTask = async () => {
  loading.value = true
  try {
    const response = await api.get(`/tasks/${route.params.id}`)
    task.value = response.data.data // L'API retourne { data: task }
  } catch (error) {
    toast.error('Erreur lors du chargement de la tâche')
    router.push('/tasks')
  } finally {
    loading.value = false
  }
}

const fetchComments = async () => {
  try {
    const response = await api.get(`/tasks/${route.params.id}/comments`)
    comments.value = response.data.data // L'API retourne { data: comments }
  } catch (error) {
    console.error('Erreur lors du chargement des commentaires:', error)
  }
}

const addComment = async () => {
  if (!newComment.value.trim()) return
  
  try {
    const response = await api.post(`/tasks/${route.params.id}/comments`, {
      content: newComment.value
    })
    comments.value.push(response.data.data) // L'API retourne { data: comment }
    newComment.value = ''
    toast.success('Commentaire ajouté')
  } catch (error) {
    toast.error('Erreur lors de l\'ajout du commentaire')
  }
}

const updateStatus = async (status) => {
  try {
    const response = await api.put(`/tasks/${route.params.id}`, { status })
    task.value = response.data.data // L'API retourne { data: task }
    toast.success('Statut mis à jour')
  } catch (error) {
    toast.error('Erreur lors de la mise à jour du statut')
  }
}

const editTask = () => {
  showEditModal.value = true
}

const deleteTask = async () => {
  if (confirm('Êtes-vous sûr de vouloir supprimer cette tâche ?')) {
    try {
      await api.delete(`/tasks/${route.params.id}`)
      toast.success('Tâche supprimée')
      router.push('/tasks')
    } catch (error) {
      toast.error('Erreur lors de la suppression')
    }
  }
}

const handleFormSubmit = async (taskData) => {
  formLoading.value = true
  try {
    const response = await api.put(`/tasks/${route.params.id}`, taskData)
    task.value = response.data.data // L'API retourne { data: task }
    showEditModal.value = false
    toast.success('Tâche mise à jour')
  } catch (error) {
    toast.error('Erreur lors de la mise à jour')
  } finally {
    formLoading.value = false
  }
}

const handleCreateFormSubmit = async (taskData) => {
  createFormLoading.value = true
  try {
    const result = await tasksStore.createTask(taskData)
    if (result.success) {
      showCreateModal.value = false
      toast.success('Tâche créée avec succès')
    }
  } catch (error) {
    toast.error('Erreur lors de la création de la tâche')
  } finally {
    createFormLoading.value = false
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

const getPriorityLabel = (priority) => {
  const labels = {
    low: 'Basse',
    medium: 'Moyenne',
    high: 'Haute'
  }
  return labels[priority] || priority
}

const getStatusVariant = (status) => {
  const variants = {
    pending: 'secondary',
    in_progress: 'default',
    completed: 'outline',
    canceled: 'destructive'
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
  if (!dateString) return 'Date invalide'
  const date = new Date(dateString)
  if (isNaN(date.getTime())) return 'Date invalide'
  
  return date.toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

onMounted(() => {
  fetchTask()
  fetchComments()
})
</script> 