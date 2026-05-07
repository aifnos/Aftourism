<template>
  <div class="page-content !mb-5">
    <ElRow justify="space-between" :gutter="10">
      <ElCol :lg="7" :md="8" :sm="12" :xs="16">
        <ElInput
          v-model="searchVal"
          :prefix-icon="Search"
          clearable
          placeholder="输入标题或作者查询"
          @keyup.enter="handleSearch"
        />
      </ElCol>
      <ElCol :lg="8" :md="8" :sm="12" :xs="8">
        <ElSelect v-model="statusVal" clearable placeholder="筛选状态" @change="handleSearch">
          <ElOption :value="-1" label="全部" />
          <ElOption :value="0" label="待审核" />
          <ElOption :value="1" label="已发布" />
          <ElOption :value="2" label="已驳回" />
        </ElSelect>
      </ElCol>
      <ElCol :lg="4" :md="4" :sm="0" :xs="0" class="flex justify-end">
        <ElButton @click="handleReset">重置</ElButton>
      </ElCol>
    </ElRow>

    <div class="mt-5">
      <div
        class="grid grid-cols-4 gap-5 max-2xl:grid-cols-3 max-xl:grid-cols-2 max-sm:grid-cols-1"
        v-loading="loading"
      >
        <div
          v-for="item in tableData"
          :key="item.id"
          class="exchange-article-card group overflow-hidden border border-g-300/60 rounded-custom-sm cursor-pointer"
          @click="openDetail(item)"
        >
          <div class="relative aspect-[16/9.5]">
            <ElImage
              class="flex align-center justify-center w-full h-full object-cover bg-gray-200"
              :src="item.coverUrl || ''"
              fit="cover"
            >
              <template #error>
                <div class="flex h-full w-full items-center justify-center text-xs text-g-500">暂无封面</div>
              </template>
            </ElImage>
            <ElTag class="absolute top-2 right-2" size="small" :type="statusTagType(item.status)">
              {{ item.statusText || statusText(item.status) }}
            </ElTag>
          </div>
          <div class="px-3 py-2">
            <h2 class="text-base text-g-800 font-medium line-clamp-1">{{ item.title }}</h2>
            <div class="mt-1 flex items-center gap-2 text-sm text-g-500">
              <ElAvatar :size="24" :src="item.userAvatar || undefined">
                {{ avatarInitial(articleUserName(item)) }}
              </ElAvatar>
              <span class="min-w-0 truncate">作者：{{ articleUserName(item) }}</span>
            </div>
            <div class="flex-b w-full h-7 mt-2 text-sm text-g-500">
              <div class="flex items-center gap-3">
                <span>👍 {{ item.likeCount || 0 }}</span>
                <span>💬 {{ item.commentCount || 0 }}</span>
                <span>{{ useDateFormat(item.createTime, 'YYYY-MM-DD') }}</span>
              </div>
              <ElButton
                class="opacity-0 group-hover:opacity-100"
                size="small"
                type="primary"
                @click.stop="openAudit(item)"
              >
                审核
              </ElButton>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div style="margin-top: 16vh" v-if="showEmpty">
      <ElEmpty description="暂无交流文章" />
    </div>

    <div style="display: flex; justify-content: center; margin-top: 20px">
      <ElPagination
        size="default"
        background
        v-model:current-page="pagination.current"
        :page-size="pagination.size"
        :pager-count="9"
        layout="prev, pager, next, total, jumper"
        :total="pagination.total"
        :hide-on-single-page="true"
        @current-change="handleCurrentChange"
      />
    </div>

    <ElDialog v-model="detailVisible" width="960px" title="交流文章详情">
      <div v-loading="detailLoading">
        <template v-if="detailArticle">
          <div class="flex flex-wrap items-center justify-between gap-3 text-sm text-g-600">
            <div>
              <div class="text-base text-g-800 font-semibold">{{ detailArticle.title }}</div>
              <div class="mt-1 flex items-center gap-2">
                <ElAvatar :size="28" :src="detailArticle.userAvatar || undefined">
                  {{ avatarInitial(articleUserName(detailArticle)) }}
                </ElAvatar>
                <span>作者：{{ articleUserName(detailArticle) }}</span>
              </div>
            </div>
            <ElTag size="small" :type="statusTagType(detailArticle.status)">
              {{ detailArticle.statusText || statusText(detailArticle.status) }}
            </ElTag>
          </div>
          <div class="mt-4 rounded-lg border border-g-200 bg-g-50/40 p-4">
            <div
              v-if="detailArticle.content"
              class="prose max-w-none text-sm text-g-700"
              v-html="detailArticle.content"
            ></div>
            <div v-else class="text-sm text-g-500">暂无文章内容</div>
          </div>
          <div class="mt-6">
            <div class="flex items-center justify-between">
              <div class="text-base font-medium text-g-800">评论</div>
              <div class="text-xs text-g-500">共 {{ commentPagination.total }} 条</div>
            </div>
            <div v-loading="commentLoading" class="mt-3 space-y-4">
              <div v-if="commentList.length === 0" class="text-sm text-g-500">暂无评论</div>
              <div
                v-for="comment in commentList"
                :key="comment.id"
                class="rounded-lg border border-g-200/70 p-4"
              >
                <div class="flex items-start justify-between gap-4">
                  <div class="flex min-w-0 flex-1 items-start gap-3">
                    <ElAvatar :size="36" :src="comment.userAvatar || undefined">
                      {{ avatarInitial(commentUserName(comment)) }}
                    </ElAvatar>
                    <div class="min-w-0 flex-1">
                    <div class="text-sm text-g-800">
                      <span class="font-medium">{{ commentUserName(comment) }}</span>
                      <span v-if="comment.mentionUserNickname" class="ml-2 text-g-500">
                        回复 @{{ comment.mentionUserNickname }}
                      </span>
                    </div>
                    <div class="mt-2 text-sm text-g-700 whitespace-pre-line">
                      {{ comment.content }}
                    </div>
                    <div class="mt-2 text-xs text-g-400">
                      {{ useDateFormat(comment.createTime, 'YYYY-MM-DD HH:mm') }}
                    </div>
                    </div>
                  </div>
                  <div class="flex items-center gap-2">
                    <ElButton size="small" @click="openEditComment(comment)">编辑</ElButton>
                    <ElButton size="small" type="danger" @click="confirmDeleteComment(comment)">删除</ElButton>
                  </div>
                </div>
                <div
                  v-if="comment.children && comment.children.length"
                  class="mt-4 space-y-3 border-t border-g-200/70 pt-3"
                >
                  <div v-for="child in comment.children" :key="child.id" class="rounded-md bg-g-100/60 p-3">
                    <div class="flex items-start justify-between gap-4">
                      <div class="flex min-w-0 flex-1 items-start gap-3">
                        <ElAvatar :size="32" :src="child.userAvatar || undefined">
                          {{ avatarInitial(commentUserName(child)) }}
                        </ElAvatar>
                        <div class="min-w-0 flex-1">
                        <div class="text-sm text-g-800">
                          <span class="font-medium">{{ commentUserName(child) }}</span>
                          <span v-if="child.mentionUserNickname" class="ml-2 text-g-500">
                            回复 @{{ child.mentionUserNickname }}
                          </span>
                        </div>
                        <div class="mt-2 text-sm text-g-700 whitespace-pre-line">
                          {{ child.content }}
                        </div>
                        <div class="mt-2 text-xs text-g-400">
                          {{ useDateFormat(child.createTime, 'YYYY-MM-DD HH:mm') }}
                        </div>
                        </div>
                      </div>
                      <div class="flex items-center gap-2">
                        <ElButton size="small" @click="openEditComment(child)">编辑</ElButton>
                        <ElButton size="small" type="danger" @click="confirmDeleteComment(child)">删除</ElButton>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div
              v-if="commentPagination.total > commentPagination.size"
              class="flex justify-center mt-5"
            >
              <ElPagination
                size="small"
                background
                v-model:current-page="commentPagination.current"
                :page-size="commentPagination.size"
                layout="prev, pager, next"
                :total="commentPagination.total"
                @current-change="handleCommentPageChange"
              />
            </div>
          </div>
        </template>
      </div>
      <template #footer>
        <ElButton @click="detailVisible = false">关闭</ElButton>
      </template>
    </ElDialog>

    <ElDialog v-model="dialogVisible" width="520px" title="交流文章审核">
      <template v-if="currentArticle">
        <div class="mb-4 text-sm text-g-600">
          <div>标题：{{ currentArticle.title }}</div>
          <div class="mt-2 flex items-center gap-2">
            <span>作者：</span>
            <ElAvatar :size="28" :src="currentArticle.userAvatar || undefined">
              {{ avatarInitial(articleUserName(currentArticle)) }}
            </ElAvatar>
            <span>{{ articleUserName(currentArticle) }}</span>
          </div>
        </div>
        <div class="mb-4 rounded-lg border border-g-200 bg-g-50/40 p-3 text-sm text-g-600">
          <div v-if="currentArticle.content" class="max-h-48 overflow-auto" v-html="currentArticle.content"></div>
          <div v-else class="text-g-500">暂无文章内容</div>
        </div>
        <ElForm ref="auditFormRef" :model="auditForm" label-width="90px">
          <ElFormItem label="审核状态">
            <ElRadioGroup v-model="auditForm.status">
              <ElRadio :label="1">通过</ElRadio>
              <ElRadio :label="2">驳回</ElRadio>
            </ElRadioGroup>
          </ElFormItem>
          <ElFormItem label="审核备注">
            <ElInput v-model="auditForm.auditRemark" type="textarea" :rows="3" maxlength="200" show-word-limit />
          </ElFormItem>
        </ElForm>
      </template>
      <template #footer>
        <ElButton @click="dialogVisible = false">取消</ElButton>
        <ElButton type="primary" @click="submitAudit">确认</ElButton>
      </template>
    </ElDialog>

    <ElDialog v-model="commentDialogVisible" width="520px" title="编辑评论">
      <ElForm ref="commentFormRef" :model="commentForm" label-width="80px">
        <ElFormItem label="评论内容" prop="content">
          <ElInput v-model="commentForm.content" type="textarea" :rows="4" maxlength="500" show-word-limit />
        </ElFormItem>
      </ElForm>
      <template #footer>
        <ElButton @click="commentDialogVisible = false">取消</ElButton>
        <ElButton type="primary" @click="submitCommentEdit">保存</ElButton>
      </template>
    </ElDialog>
  </div>
</template>

<script setup lang="ts">
  import { Search } from '@element-plus/icons-vue'
  import { useDateFormat } from '@vueuse/core'
  import { computed, reactive, ref, onMounted, watch } from 'vue'
  import { useRoute } from 'vue-router'
  import { ElAvatar, ElMessage, ElMessageBox, type FormInstance } from 'element-plus'
  import { useTable } from '@/hooks/core/useTable'
  import {
    fetchExchangeArticleDetail,
    fetchExchangeArticlePage,
    auditExchangeArticle,
    fetchExchangeCommentPage,
    updateExchangeComment,
    deleteExchangeComment
  } from '@/api/exchange'

  defineOptions({ name: 'ExchangeArticleManage' })

  type ExchangeArticleItem = Api.Exchange.ExchangeArticleItem

  const searchVal = ref('')
  const statusVal = ref<number>(-1)
  const route = useRoute()

  const { data, loading, pagination, getData, searchParams, handleCurrentChange } = useTable({
    core: {
      apiFn: fetchExchangeArticlePage,
      apiParams: { current: 1, size: 12 }
    },
    transform: {
      responseAdapter: (response) => ({
        records: response.list,
        total: response.total,
        current: response.pageNum,
        size: response.pageSize
      })
    }
  })

  const tableData = computed(() => data.value || [])
  const showEmpty = computed(() => tableData.value.length === 0 && !loading.value)

  const statusText = (status?: number) => {
    if (status === 1) return '已发布'
    if (status === 2) return '已驳回'
    return '待审核'
  }

  const statusTagType = (status?: number) => {
    if (status === 1) return 'success'
    if (status === 2) return 'danger'
    return 'warning'
  }

  const articleUserName = (item?: Pick<ExchangeArticleItem, 'userNickname' | 'userName'> | null) => {
    return item?.userNickname || item?.userName || '未知用户'
  }

  const commentUserName = (item?: Api.Exchange.ExchangeCommentItem | null) => {
    return item?.userNickname || (item?.userId ? `用户${item.userId}` : '未知用户')
  }

  const avatarInitial = (name?: string) => name?.trim().slice(0, 1) || '游'

  const handleSearch = () => {
    Object.assign(searchParams, {
      current: 1,
      status: statusVal.value === -1 ? undefined : statusVal.value,
      keyword: searchVal.value || undefined
    })
    getData()
  }

  const handleReset = () => {
    searchVal.value = ''
    statusVal.value = -1
    Object.assign(searchParams, { current: 1, status: undefined, keyword: undefined })
    getData()
  }

  const dialogVisible = ref(false)
  const currentArticle = ref<ExchangeArticleItem | null>(null)
  const auditFormRef = ref<FormInstance>()
  const auditForm = reactive({ status: 1, auditRemark: '' })

  const detailVisible = ref(false)
  const detailLoading = ref(false)
  const detailArticle = ref<ExchangeArticleItem | null>(null)
  const commentLoading = ref(false)
  const commentList = ref<Api.Exchange.ExchangeCommentItem[]>([])
  const commentPagination = reactive({ current: 1, size: 6, total: 0 })
  const commentDialogVisible = ref(false)
  const commentFormRef = ref<FormInstance>()
  const commentForm = reactive({ content: '' })
  const currentComment = ref<Api.Exchange.ExchangeCommentItem | null>(null)

  const fetchArticleDetail = async (id: number) => {
    return fetchExchangeArticleDetail(id)
  }

  const openAudit = async (row: ExchangeArticleItem) => {
    const detail = row.content ? row : await fetchArticleDetail(row.id)
    currentArticle.value = detail
    auditForm.status = detail.status === 2 ? 2 : 1
    auditForm.auditRemark = detail.auditRemark || ''
    dialogVisible.value = true
  }

  const openAuditById = async (id: number) => {
    if (!id) return
    await openAudit({ id } as ExchangeArticleItem)
  }

  const openDetail = async (row: ExchangeArticleItem) => {
    detailVisible.value = true
    detailLoading.value = true
    commentPagination.current = 1
    try {
      const detail = await fetchArticleDetail(row.id)
      detailArticle.value = detail
      await loadComments(detail.id)
    } finally {
      detailLoading.value = false
    }
  }

  const loadComments = async (articleId: number) => {
    commentLoading.value = true
    try {
      const res = await fetchExchangeCommentPage(articleId, {
        current: commentPagination.current,
        size: commentPagination.size
      })
      commentList.value = res.list || []
      commentPagination.total = res.total || 0
      commentPagination.current = res.pageNum || commentPagination.current
      commentPagination.size = res.pageSize || commentPagination.size
    } finally {
      commentLoading.value = false
    }
  }

  const handleCommentPageChange = async (page: number) => {
    commentPagination.current = page
    if (detailArticle.value) {
      await loadComments(detailArticle.value.id)
    }
  }

  const openEditComment = (comment: Api.Exchange.ExchangeCommentItem) => {
    currentComment.value = comment
    commentForm.content = comment.content || ''
    commentDialogVisible.value = true
  }

  const submitCommentEdit = async () => {
    if (!commentFormRef.value || !currentComment.value) return
    await commentFormRef.value.validate()
    await updateExchangeComment(currentComment.value.id, {
      content: commentForm.content
    })
    commentDialogVisible.value = false
    if (detailArticle.value) {
      await loadComments(detailArticle.value.id)
    }
  }

  const confirmDeleteComment = async (comment: Api.Exchange.ExchangeCommentItem) => {
    await ElMessageBox.confirm('确认删除该评论吗？', '删除确认', { type: 'warning' })
    await deleteExchangeComment(comment.id)
    if (detailArticle.value) {
      await loadComments(detailArticle.value.id)
    }
  }

  const submitAudit = async () => {
    if (!currentArticle.value) return
    if (!auditFormRef.value) return
    await auditFormRef.value.validate()
    await auditExchangeArticle(currentArticle.value.id, {
      status: auditForm.status,
      auditRemark: auditForm.auditRemark || undefined
    })
    ElMessage.success('审核已更新')
    dialogVisible.value = false
    getData()
  }

  const tryOpenFromQuery = () => {
    const id = Number(route.query.id)
    if (Number.isNaN(id) || !id) return
    void openAuditById(id)
  }

  onMounted(() => {
    tryOpenFromQuery()
  })

  watch(
    () => route.query.id,
    () => {
      tryOpenFromQuery()
    }
  )
</script>

<style scoped lang="scss">
  .page-content {
    padding: 24px;
  }

  .exchange-article-card {
    transition: transform 0.2s ease, box-shadow 0.2s ease;
  }

  .exchange-article-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 12px 24px rgba(15, 23, 42, 0.08);
  }
</style>
