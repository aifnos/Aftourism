<template>
  <div class="portal-map-page" :class="{ 'sidebar-closed': !isSidebarOpen }">
    <aside class="map-sidebar">
      <div class="sidebar-header">
        <div class="header-title-row">
          <div>
            <h1>文旅地图</h1>
            <p>景区与场馆点位总览</p>
          </div>
          <div class="count-badge">{{ filteredList.length }}</div>
        </div>

        <el-radio-group v-model="selectedType" class="type-tabs" @change="handleTypeChange">
          <el-radio-button label="all">全部 {{ allItems.length }}</el-radio-button>
          <el-radio-button label="scenic">景区 {{ scenicCount }}</el-radio-button>
          <el-radio-button label="venue">场馆 {{ venueCount }}</el-radio-button>
        </el-radio-group>

        <div class="search-row">
          <el-input
            v-model="keyword"
            placeholder="搜索名称、地址或标签"
            clearable
            :prefix-icon="Search"
          />
          <el-button type="primary" plain @click="fitBounds">全景</el-button>
        </div>
      </div>

      <el-scrollbar ref="listScrollbar" class="map-list" v-loading="loading">
        <div
          v-for="item in filteredList"
          :key="item.key"
          class="map-list-item"
          :class="[item.kind, { active: activeKey === item.key }]"
          @click="handleItemClick(item)"
        >
          <div class="item-main">
            <div class="name" :title="item.name">{{ item.name }}</div>
            <el-tag size="small" :type="item.kind === 'scenic' ? 'success' : 'warning'" effect="plain">
              {{ item.primaryLabel }}
            </el-tag>
          </div>
          <div class="meta-row">
            <span class="kind-label">{{ item.kindName }}</span>
            <span v-if="item.secondaryLabel">{{ item.secondaryLabel }}</span>
          </div>
          <div class="coord-row">
            <el-icon><Location /></el-icon>
            <span>{{ item.latitude.toFixed(2) }}, {{ item.longitude.toFixed(2) }}</span>
          </div>
        </div>

        <div v-if="!loading && filteredList.length === 0" class="empty-state">
          <el-empty description="未找到匹配点位" :image-size="104" />
        </div>
      </el-scrollbar>
    </aside>

    <main ref="mapEl" class="map-box"></main>

    <div class="map-controls">
      <button class="control-btn" type="button" @click="toggleSidebar" title="切换列表">
        <el-icon size="18">
          <ArrowLeft v-if="isSidebarOpen" />
          <ArrowRight v-else />
        </el-icon>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { ElMessage } from 'element-plus';
import { ArrowLeft, ArrowRight, Location, Search } from '@element-plus/icons-vue';
import { fetchScenicPage, fetchVenuePage, type ScenicItem, type VenueItem } from '@/services/portal';
import {
  loadLeaflet,
  type LeafletCircleMarker,
  type LeafletLayerGroup,
  type LeafletMap,
  type LeafletTileLayer
} from '@/utils/leaflet';

defineOptions({ name: 'PortalMap' });

type MapPointKind = 'scenic' | 'venue';
type MapMode = 'all' | MapPointKind;

interface MapPoint {
  key: string;
  id: number;
  kind: MapPointKind;
  kindName: string;
  name: string;
  latitude: number;
  longitude: number;
  address?: string;
  tags?: string;
  imageUrl?: string;
  primaryLabel: string;
  secondaryLabel?: string;
  color: string;
  hoverColor: string;
  activeColor: string;
}

interface MarkerRecord {
  item: MapPoint;
  marker: LeafletCircleMarker;
}

const MAP_CENTER: [number, number] = [29.65, 91.11];
const SCENIC_COLOR = '#2f8cff';
const VENUE_COLOR = '#f59e0b';

const route = useRoute();
const router = useRouter();
const map = ref<LeafletMap | null>(null);
const mapEl = ref<HTMLElement | null>(null);
const tileLayer = ref<LeafletTileLayer | null>(null);
const layerGroup = ref<LeafletLayerGroup | null>(null);
const allItems = ref<MapPoint[]>([]);
const keyword = ref('');
const selectedType = ref<MapMode>('all');
const activeKey = ref<string | null>(null);
const loading = ref(false);
const isSidebarOpen = ref(window.innerWidth > 768);
const listScrollbar = ref<{ setScrollTop?: (value: number) => void } | null>(null);
const markerMap = new Map<string, MarkerRecord>();
let mapClickHandler: ((event: MouseEvent) => void) | null = null;

const scenicCount = computed(() => allItems.value.filter((item) => item.kind === 'scenic').length);
const venueCount = computed(() => allItems.value.filter((item) => item.kind === 'venue').length);

const filteredList = computed(() => {
  const normalizedKeyword = keyword.value.trim().toLowerCase();
  return allItems.value.filter((item) => {
    const typeMatched = selectedType.value === 'all' || item.kind === selectedType.value;
    if (!typeMatched) return false;
    if (!normalizedKeyword) return true;
    return [item.name, item.address, item.tags, item.primaryLabel, item.secondaryLabel]
      .filter(Boolean)
      .some((value) => String(value).toLowerCase().includes(normalizedKeyword));
  });
});

const normalizeMode = (value: unknown): MapMode => {
  if (value === 'scenic' || value === 'venue') return value;
  return 'all';
};

const splitTags = (tags?: string) => {
  if (!tags) return [];
  return tags.split(/[;,，\s]+/).map((tag) => tag.trim()).filter(Boolean);
};

const escapeHtml = (value?: string | number) =>
  String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');

const scenicToPoint = (item: ScenicItem): MapPoint | null => {
  const { latitude, longitude } = item;
  if (
    typeof latitude !== 'number' ||
    typeof longitude !== 'number' ||
    !Number.isFinite(latitude) ||
    !Number.isFinite(longitude)
  ) {
    return null;
  }
  const pointLatitude = latitude as number;
  const pointLongitude = longitude as number;
  return {
    key: `scenic-${item.id}`,
    id: item.id,
    kind: 'scenic',
    kindName: '景区',
    name: item.name,
    latitude: pointLatitude,
    longitude: pointLongitude,
    address: item.address,
    tags: item.tags,
    imageUrl: item.imageUrl,
    primaryLabel: item.level || '普通景区',
    secondaryLabel: item.city || item.district,
    color: SCENIC_COLOR,
    hoverColor: '#0f76ff',
    activeColor: '#1d4ed8'
  };
};

const venueToPoint = (item: VenueItem): MapPoint | null => {
  const { latitude, longitude } = item;
  if (
    typeof latitude !== 'number' ||
    typeof longitude !== 'number' ||
    !Number.isFinite(latitude) ||
    !Number.isFinite(longitude)
  ) {
    return null;
  }
  const pointLatitude = latitude as number;
  const pointLongitude = longitude as number;
  return {
    key: `venue-${item.id}`,
    id: item.id,
    kind: 'venue',
    kindName: '场馆',
    name: item.name,
    latitude: pointLatitude,
    longitude: pointLongitude,
    address: item.address,
    tags: item.tags,
    imageUrl: item.imageUrl,
    primaryLabel: item.isFree === 1 ? '免费' : '收费',
    secondaryLabel: item.category || '综合场馆',
    color: VENUE_COLOR,
    hoverColor: '#d97706',
    activeColor: '#b45309'
  };
};

const handleTypeChange = (value: string | number | boolean | undefined) => {
  const mode = normalizeMode(value);
  selectedType.value = mode;
  router.replace({
    path: '/map',
    query: mode === 'all' ? {} : { type: mode }
  });
};

const toggleSidebar = () => {
  isSidebarOpen.value = !isSidebarOpen.value;
  setTimeout(() => {
    map.value?.invalidateSize();
  }, 300);
};

const initMap = async () => {
  if (map.value || !mapEl.value) return;
  const L = await loadLeaflet();
  map.value = L.map(mapEl.value, {
    preferCanvas: true,
    zoomControl: false
  }).setView(MAP_CENTER, 7);

  L.control.zoom({ position: 'topright' }).addTo(map.value);
  tileLayer.value = L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/light_all/{z}/{x}/{y}{r}.png', {
    subdomains: 'abcd',
    maxZoom: 20,
    attribution: '&copy; OpenStreetMap &copy; CARTO'
  }).addTo(map.value);
  layerGroup.value = L.layerGroup().addTo(map.value);

  mapClickHandler = (event: MouseEvent) => {
    const target = event.target as HTMLElement;
    const button = target.closest<HTMLButtonElement>('.go-detail-btn');
    if (!button) return;
    const id = Number(button.dataset.id);
    const kind = button.dataset.kind as MapPointKind | undefined;
    if (!id || (kind !== 'scenic' && kind !== 'venue')) return;
    router.push(kind === 'scenic' ? `/scenic/${id}` : `/venues/${id}`);
  };
  map.value.getContainer().addEventListener('click', mapClickHandler);
};

const loadData = async () => {
  loading.value = true;
  try {
    const [scenicRes, venueRes] = await Promise.all([
      fetchScenicPage({ current: 1, size: 1000 }),
      fetchVenuePage({ current: 1, size: 1000 })
    ]);
    const scenics = (scenicRes.list || []).map(scenicToPoint).filter((item): item is MapPoint => Boolean(item));
    const venues = (venueRes.list || []).map(venueToPoint).filter((item): item is MapPoint => Boolean(item));
    allItems.value = [...scenics, ...venues];
    await renderMarkers();
  } catch (error) {
    console.error('Failed to load portal map data:', error);
    ElMessage.error('地图点位加载失败');
  } finally {
    loading.value = false;
  }
};

const createPopupContent = (item: MapPoint) => {
  const summary = splitTags(item.tags).slice(0, 3).join(' · ') || '暂无标签';
  const imageHtml = item.imageUrl
    ? `<img class="popup-cover" src="${escapeHtml(item.imageUrl)}" alt="${escapeHtml(item.name)}" />`
    : '';
  return `
    <div class="map-popup-card ${item.kind}-popup">
      ${imageHtml}
      <div class="popup-header">
        <h3>${escapeHtml(item.name)}</h3>
        <span class="badge">${escapeHtml(item.primaryLabel)}</span>
      </div>
      <div class="popup-body">
        <div class="meta-row">${escapeHtml(item.kindName)}${item.secondaryLabel ? ` · ${escapeHtml(item.secondaryLabel)}` : ''}</div>
        <p class="desc">${escapeHtml(summary)}</p>
        <p class="address">${escapeHtml(item.address || '暂无地址信息')}</p>
      </div>
      <div class="popup-footer">
        <button class="go-detail-btn" data-kind="${item.kind}" data-id="${item.id}" type="button">
          查看详情
        </button>
      </div>
    </div>
  `;
};

const resetActiveMarker = () => {
  if (!activeKey.value) return;
  const activeRecord = markerMap.get(activeKey.value);
  if (activeRecord) {
    activeRecord.marker.setStyle({ fillColor: activeRecord.item.color, radius: 7 });
  }
  activeKey.value = null;
};

const renderMarkers = async () => {
  if (!layerGroup.value || !map.value) return;
  const L = await loadLeaflet();
  resetActiveMarker();
  layerGroup.value.clearLayers();
  markerMap.clear();

  filteredList.value.forEach((item) => {
    L.circleMarker([item.latitude, item.longitude], {
      radius: 18,
      stroke: false,
      fillColor: item.color,
      fillOpacity: 0.16,
      className: `${item.kind}-marker-halo`
    }).addTo(layerGroup.value!);

    const marker = L.circleMarker([item.latitude, item.longitude], {
      radius: 7,
      color: '#ffffff',
      weight: 2,
      fillColor: item.color,
      fillOpacity: 1,
      className: `${item.kind}-marker-core`
    }).addTo(layerGroup.value!);

    marker.bindPopup(createPopupContent(item), {
      maxWidth: 288,
      className: 'custom-leaflet-popup',
      closeButton: false
    });

    marker.on('click', () => {
      setActive(item.key);
      marker.openPopup();
    });

    marker.on('mouseover', () => {
      marker.setStyle({ radius: 9, fillColor: item.hoverColor });
    });

    marker.on('mouseout', () => {
      if (activeKey.value !== item.key) {
        marker.setStyle({ radius: 7, fillColor: item.color });
      }
    });

    markerMap.set(item.key, { item, marker });
  });

  nextTick(() => {
    map.value?.invalidateSize();
    fitBounds();
  });
};

const setActive = (key: string) => {
  if (activeKey.value && activeKey.value !== key) {
    const previous = markerMap.get(activeKey.value);
    if (previous) {
      previous.marker.setStyle({ fillColor: previous.item.color, radius: 7 });
    }
  }

  activeKey.value = key;
  const current = markerMap.get(key);
  if (current) {
    current.marker.setStyle({ fillColor: current.item.activeColor, radius: 9 });
  }
  scrollToItem();
};

const handleItemClick = (item: MapPoint) => {
  setActive(item.key);
  map.value?.flyTo([item.latitude, item.longitude], 12, { duration: 0.8 });
  markerMap.get(item.key)?.marker.openPopup();
};

const fitBounds = () => {
  if (!map.value) return;
  if (filteredList.value.length === 0) {
    map.value.setView(MAP_CENTER, 7);
    return;
  }
  if (filteredList.value.length === 1) {
    const [item] = filteredList.value;
    map.value.flyTo([item.latitude, item.longitude], 12, { duration: 0.5 });
    return;
  }
  const bounds = filteredList.value.map((item) => [item.latitude, item.longitude] as [number, number]);
  map.value.fitBounds(bounds, { padding: [52, 52], maxZoom: 12 });
};

const scrollToItem = () => {
  nextTick(() => {
    const itemEl = document.querySelector('.map-list-item.active') as HTMLElement | null;
    const wrapEl = document.querySelector('.map-list .el-scrollbar__wrap') as HTMLElement | null;
    if (itemEl && wrapEl) {
      const centerOffset = Math.max(0, (wrapEl.clientHeight - itemEl.clientHeight) / 2);
      wrapEl.scrollTo({ top: Math.max(0, itemEl.offsetTop - centerOffset), behavior: 'smooth' });
    }
    if (listScrollbar.value?.setScrollTop && itemEl) {
      listScrollbar.value.setScrollTop(Math.max(0, itemEl.offsetTop - 72));
    }
  });
};

watch(
  () => route.query.type,
  (type) => {
    const mode = normalizeMode(type);
    if (selectedType.value !== mode) {
      selectedType.value = mode;
    }
  },
  { immediate: true }
);

watch([selectedType, keyword], () => {
  renderMarkers();
});

onMounted(async () => {
  await initMap();
  await loadData();
});

onUnmounted(() => {
  if (map.value && mapClickHandler) {
    map.value.getContainer().removeEventListener('click', mapClickHandler);
  }
  if (map.value) {
    map.value.remove();
    map.value = null;
  }
});
</script>

<style scoped lang="scss">
.portal-map-page {
  height: calc(100vh - 72px);
  min-height: 620px;
  display: flex;
  position: relative;
  overflow: hidden;
  background: #eef3f8;
}

.map-sidebar {
  width: 368px;
  height: 100%;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  border-right: 1px solid #dce5ef;
  background: #ffffff;
  z-index: 10;
  transition: width 0.28s ease, opacity 0.28s ease;
}

.portal-map-page.sidebar-closed .map-sidebar {
  width: 0;
  opacity: 0;
  overflow: hidden;
  border-right: none;
}

.sidebar-header {
  padding: 20px;
  border-bottom: 1px solid #edf1f5;
  background: #ffffff;
}

.header-title-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 16px;

  h1 {
    margin: 0 0 6px;
    color: #18212f;
    font-size: 22px;
    line-height: 1.2;
    font-weight: 700;
  }

  p {
    margin: 0;
    color: #667085;
    font-size: 13px;
  }
}

.count-badge {
  min-width: 36px;
  height: 28px;
  padding: 0 10px;
  border-radius: 999px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: #1d4ed8;
  background: #e8f1ff;
  font-size: 13px;
  font-weight: 700;
}

.type-tabs {
  width: 100%;
  margin-bottom: 14px;

  :deep(.el-radio-button) {
    flex: 1;
  }

  :deep(.el-radio-button__inner) {
    width: 100%;
    padding: 9px 0;
  }
}

.search-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.map-list {
  flex: 1;
  padding: 12px;
  background: #f7f9fc;
}

.map-list-item {
  padding: 13px 12px;
  margin-bottom: 10px;
  border: 1px solid transparent;
  border-radius: 8px;
  background: #ffffff;
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;

  &:hover {
    transform: translateY(-1px);
    box-shadow: 0 8px 20px rgba(16, 24, 40, 0.08);
    border-color: #d8e3f1;
  }

  &.scenic.active {
    border-color: #2f8cff;
    background: #edf5ff;

    .name {
      color: #1d4ed8;
    }
  }

  &.venue.active {
    border-color: #f59e0b;
    background: #fff7ed;

    .name {
      color: #b45309;
    }
  }
}

.item-main {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 8px;
  margin-bottom: 8px;
}

.name {
  flex: 1;
  min-width: 0;
  color: #273142;
  font-size: 14px;
  font-weight: 650;
  line-height: 1.4;
  overflow-wrap: anywhere;
}

.meta-row,
.coord-row {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #778294;
  font-size: 12px;
  line-height: 1.4;
}

.meta-row {
  margin-bottom: 5px;
}

.kind-label {
  color: #344054;
  font-weight: 600;
}

.coord-row {
  gap: 4px;

  .el-icon {
    font-size: 14px;
  }
}

.empty-state {
  padding-top: 40px;
}

.map-box {
  flex: 1;
  height: 100%;
  position: relative;
  z-index: 1;
  background: #e7edf4;
}

.map-controls {
  position: absolute;
  top: 16px;
  left: 384px;
  z-index: 1000;
  transition: left 0.28s ease;
}

.portal-map-page.sidebar-closed .map-controls {
  left: 16px;
}

.control-btn {
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #475467;
  background: #ffffff;
  box-shadow: 0 8px 24px rgba(16, 24, 40, 0.16);
  cursor: pointer;
  transition: color 0.2s ease, transform 0.2s ease;

  &:hover {
    color: #2563eb;
    transform: translateY(-1px);
  }
}

:deep(.leaflet-popup-content-wrapper) {
  padding: 0;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 10px 28px rgba(16, 24, 40, 0.22);
}

:deep(.leaflet-popup-content) {
  width: 100% !important;
  margin: 0;
}

:deep(.map-popup-card) {
  width: 268px;
  background: #ffffff;

  .popup-cover {
    display: block;
    width: 100%;
    height: 136px;
    object-fit: cover;
    background: #f2f4f7;
  }

  .popup-header {
    padding: 12px 14px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    color: #ffffff;

    h3 {
      margin: 0;
      font-size: 15px;
      line-height: 1.35;
      font-weight: 700;
      overflow-wrap: anywhere;
    }

    .badge {
      flex-shrink: 0;
      padding: 2px 6px;
      border-radius: 4px;
      background: rgba(255, 255, 255, 0.22);
      font-size: 11px;
      font-weight: 600;
    }
  }

  &.scenic-popup .popup-header {
    background: linear-gradient(135deg, #2f8cff 0%, #1d4ed8 100%);
  }

  &.venue-popup .popup-header {
    background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
  }

  .popup-body {
    padding: 12px 14px;

    .meta-row {
      margin-bottom: 6px;
      color: #475467;
      font-size: 12px;
      font-weight: 650;
    }

    .desc,
    .address {
      margin: 0;
      color: #667085;
      font-size: 12px;
      line-height: 1.45;
    }

    .desc {
      margin-bottom: 8px;
      color: #344054;
    }
  }

  .popup-footer {
    padding: 0 14px 14px;

    .go-detail-btn {
      width: 100%;
      height: 34px;
      border: 1px solid #2f8cff;
      border-radius: 4px;
      color: #1d4ed8;
      background: #ffffff;
      cursor: pointer;
      font-size: 13px;
      font-weight: 600;
      transition: background-color 0.2s ease, color 0.2s ease;

      &:hover {
        color: #ffffff;
        background: #2563eb;
      }
    }
  }

  &.venue-popup .popup-footer .go-detail-btn {
    border-color: #f59e0b;
    color: #b45309;

    &:hover {
      color: #ffffff;
      background: #d97706;
    }
  }
}

@media (max-width: 768px) {
  .portal-map-page {
    height: calc(100vh - 72px);
    min-height: 560px;
    display: block;
  }

  .map-sidebar {
    position: absolute;
    inset: 0 auto 0 0;
    width: min(320px, 84vw);
    box-shadow: 8px 0 24px rgba(16, 24, 40, 0.16);
  }

  .portal-map-page.sidebar-closed .map-sidebar {
    width: min(320px, 84vw);
    opacity: 1;
    transform: translateX(-100%);
  }

  .map-box {
    width: 100%;
  }

  .map-controls {
    top: 12px;
    left: 12px;
    transition: left 0.28s ease;
  }

  .portal-map-page:not(.sidebar-closed) .map-controls {
    left: min(332px, calc(84vw + 12px));
  }

  .sidebar-header {
    padding: 16px;
  }

  .search-row {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>
