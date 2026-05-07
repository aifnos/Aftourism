<template>
  <div class="layout" :class="{ 'map-layout': $route.meta.fullscreenMap }">
    <NProgressBar />
    <el-container class="content-shell">
      <el-header height="72px" class="header">
        <HeaderNav />
      </el-header>
      <el-main class="main-area">
        <router-view v-slot="{ Component }">
          <transition name="fade-slide">
            <component :is="Component" :key="$route.meta.fullscreenMap ? $route.path : $route.fullPath" />
          </transition>
        </router-view>
      </el-main>
      <el-footer v-if="!$route.meta.fullscreenMap" height="auto" class="footer">
        <FooterBar />
      </el-footer>
    </el-container>
    <el-backtop v-if="!$route.meta.fullscreenMap" :bottom="36" :right="28" class="custom-backtop" />
  </div>
</template>

<script setup lang="ts">
import HeaderNav from '@/components/HeaderNav.vue';
import FooterBar from '@/components/FooterBar.vue';
import NProgressBar from '@/components/NProgressBar.vue';
</script>

<style scoped>
.layout {
  min-height: 100vh;
  background: var(--bg-body);
  position: relative;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.layout.map-layout {
  background: #eef3f8;
}

.content-shell {
  position: relative;
  z-index: 1;
  display: flex;
  flex-direction: column;
  flex: 1;
}

.header {
  background: var(--bg-card);
  box-shadow: var(--shadow-card);
  padding: 0 24px;
  position: sticky;
  top: 0;
  z-index: 100;
  flex-shrink: 0;
}

.main-area {
  padding: 0;
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  scrollbar-gutter: stable both-edges;
}

.map-layout .main-area {
  overflow: hidden;
  scrollbar-gutter: auto;
}

.footer {
  background: #1f2937;
  color: #9ca3af;
  text-align: center;
  border-top: none;
  flex-shrink: 0;
  backface-visibility: hidden;
  transform: translateZ(0);
}

.fade-slide-enter-active,
.fade-slide-leave-active {
  transition: opacity 0.35s ease, transform 0.35s ease;
  will-change: opacity, transform;
}

.fade-slide-enter-from,
.fade-slide-leave-to {
  opacity: 0;
  transform: translateY(12px);
}

@media screen and (max-width: 768px) {
  .custom-backtop {
    bottom: 160px !important;
    right: 20px !important;
  }
}
</style>
