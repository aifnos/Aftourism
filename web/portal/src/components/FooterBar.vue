<template>
  <div class="footer-wrapper">
    <div class="footer-container">
      <div class="footer-left">
        <h3 class="footer-title">Aftourism 西藏文旅</h3>
        <p class="footer-desc">
          汇聚西藏热门景区、公共文化场馆、特色活动与游客交流内容，为出行规划、活动报名和文旅服务反馈提供统一入口。
        </p>
        <div class="social-links">
          <el-icon :size="24" title="在线咨询"><ChatDotRound /></el-icon>
          <el-icon :size="24" title="服务分享"><Share /></el-icon>
          <el-icon :size="24" title="影像活动"><Camera /></el-icon>
        </div>
      </div>

      <div class="footer-links">
        <div class="link-column">
          <h4>文旅入口</h4>
          <router-link to="/scenic">A级景区</router-link>
          <router-link to="/venues">文化场馆</router-link>
          <router-link to="/activities">特色活动</router-link>
        </div>
        <div class="link-column">
          <h4>用户服务</h4>
          <router-link to="/news">文旅资讯</router-link>
          <router-link to="/exchange">交流社区</router-link>
          <router-link to="/feedback">意见反馈</router-link>
        </div>
        <div class="link-column">
          <h4>联系我们</h4>
          <span class="info-line">服务电话：0891-6601000</span>
          <span class="info-line">服务邮箱：service@aftourism.cn</span>
          <span class="info-line">服务时间：09:00-18:00</span>
        </div>
      </div>
    </div>

    <div class="footer-bottom">
      <div class="copyright">
        © 2026 Aftourism 西藏文旅 · All Rights Reserved
      </div>
      <div class="beian">
        西藏文旅综合服务平台
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ChatDotRound, Camera, Share } from '@element-plus/icons-vue';
// 底部栏组件，包含品牌介绍、快速链接及版权信息
</script>

<style scoped lang="scss">
.footer-wrapper {
  padding: 40px 0 20px;
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  color: #9ca3af;
}

.footer-container {
  display: flex;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 40px;
  padding-bottom: 30px;
  border-bottom: 1px solid #374151;
}

.footer-left {
  flex: 1;
  min-width: 280px;
  max-width: 400px;
}

.footer-title {
  font-size: 24px;
  color: #fff;
  margin-bottom: 16px;
  font-weight: 600;
}

.footer-desc {
  font-size: 14px;
  line-height: 1.6;
  margin-bottom: 20px;
  color: #9ca3af;
}

.social-links {
  display: flex;
  gap: 16px;
}

.social-links .el-icon {
  cursor: pointer;
  transition: color 0.3s;
  color: #9ca3af;
}

.social-links .el-icon:hover {
  color: #fff;
}

.footer-links {
  display: flex;
  gap: 60px;
  flex-wrap: wrap;
}

.link-column h4 {
  font-size: 16px;
  color: #fff;
  margin-bottom: 16px;
  font-weight: 600;
}

.link-column a {
  display: block;
  font-size: 14px;
  color: #9ca3af;
  margin-bottom: 10px;
  text-decoration: none;
  transition: color 0.3s;
}

.link-column a:hover {
  color: #fff;
}

.info-line {
  display: block;
  font-size: 14px;
  color: #9ca3af;
  margin-bottom: 10px;
}

.footer-bottom {
  padding-top: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  font-size: 13px;
  gap: 10px;
}

.footer-bottom a {
  color: #9ca3af;
  text-decoration: none;
  transition: color 0.3s;
}

.footer-bottom a:hover {
  color: #fff;
}

/* 响应式适配 */
@media (max-width: 768px) {
  .footer-container {
    flex-direction: column;
    gap: 30px;
  }

  .footer-links {
    gap: 30px;
    width: 100%;
    justify-content: space-between;
  }

  .footer-bottom {
    flex-direction: column;
    align-items: center;
    text-align: center;
  }
}
</style>
