<template>
  <div class="art-card p-5 flex-b mb-5 max-sm:mb-4">
    <div>
      <h2 class="text-2xl font-medium">关于项目</h2>
      <p class="text-g-700 mt-1">{{ systemName }} 是面向西藏文旅运营的综合管理后台</p>
      <p class="text-g-700 mt-1">覆盖内容发布、景区场馆、活动审核、用户服务与运行监控</p>

      <div class="flex flex-wrap gap-3.5 max-w-150 mt-9">
        <div
          class="w-60 flex-cb h-12.5 px-3.5 border border-g-300 c-p rounded-lg text-sm bg-g-100 duration-300 hover:-translate-y-1 max-sm:w-full"
          v-for="link in linkList"
          :key="link.label"
          @click="goPage(link.url)"
        >
          <span class="text-g-700">{{ link.label }}</span>
          <ArtSvgIcon icon="ri:arrow-right-s-line" class="text-lg text-g-600" />
        </div>
      </div>
    </div>
    <img class="w-75 max-md:!hidden" src="@imgs/draw/draw1.png" alt="draw1" />
  </div>
</template>

<script setup lang="ts">
  import AppConfig from '@/config'

  const systemName = AppConfig.systemInfo.name

  const linkList = [
    { label: '工作台', url: '/dashboard/console' },
    { label: '新闻管理', url: '/news/newspage' },
    { label: '活动管理', url: '/activity/activitypage' },
    { label: '系统设置', url: '/system/home-config' }
  ]

  /**
   * 在新标签页中打开指定 URL
   * @param url 要打开的网页地址
   */
  const goPage = (url: string): void => {
    window.location.href = url
  }
</script>
