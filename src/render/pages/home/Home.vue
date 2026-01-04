<template>
  <div class="home">
    <div class="beatmap-filter">
      <div
        class="beatmap-filter-background"
        :style="{
          backgroundImage: sets[0]
            ? `url(https://a.sayobot.cn/beatmaps/${sets[0].id}/covers/cover.webp)`
            : 'none',
        }"
      ></div>
      <h1 class="page-title">铺面列表</h1>
      <div class="search">
        <el-input
          class="filter-search-input"
          suffix-icon="el-icon-search"
          placeholder="搜索关键字..."
          v-model="keyword"
          @change="onSearch"
        />
      </div>
      <table class="conditions">
        <tbody>
          <tr>
            <td class="condition-header" width="60">模式</td>
            <td class="condition-content">
              <el-checkbox-group v-model="filter.mode" size="mini">
                <el-checkbox-button
                  v-for="option in modeOptions"
                  :key="option"
                  :label="option.value"
                  :class="filterBtnClass"
                >{{ option.label }}</el-checkbox-button>
              </el-checkbox-group>
            </td>
          </tr>
          <tr>
            <td class="condition-header" width="60">分类</td>
            <td class="condition-content">
              <el-checkbox-group v-model="filter.approved" size="mini">
                <el-checkbox-button
                  v-for="option in approvedOptions"
                  :key="option"
                  :label="option.value"
                  :class="filterBtnClass"
                >{{ option.label }}</el-checkbox-button>
              </el-checkbox-group>
            </td>
          </tr>
          <tr>
            <td class="condition-header" width="60">流派</td>
            <td class="condition-content">
              <el-checkbox-group v-model="filter.genre" size="mini">
                <el-checkbox-button
                  v-for="option in genreOptions"
                  :key="option"
                  :label="option.value"
                  :class="filterBtnClass"
                >{{ option.label }}</el-checkbox-button>
              </el-checkbox-group>
            </td>
          </tr>
          <tr>
            <td class="condition-header" width="60">语言</td>
            <td class="condition-content">
              <el-checkbox-group v-model="filter.language" size="mini">
                <el-checkbox-button
                  v-for="option in languageOptions"
                  :key="option"
                  :label="option.value"
                  :class="filterBtnClass"
                >{{ option.label }}</el-checkbox-button>
              </el-checkbox-group>
            </td>
          </tr>
          <tr>
            <td class="condition-header" width="60">难度</td>
            <td class="condition-content" style="padding-right: 15px">
              <el-slider v-model="filter.stars" range :max="MAX_STARS" :step="0.1" size="small" />
            </td>
          </tr>
          <tr>
            <td class="condition-header" width="60">CS</td>
            <td class="condition-content" style="padding-right: 15px">
              <el-slider v-model="filter.cs" range :max="MAX_CS" :step="0.1" size="small" />
            </td>
          </tr>
          <tr>
            <td class="condition-header" width="60">AR</td>
            <td class="condition-content" style="padding-right: 15px">
              <el-slider v-model="filter.ar" range :max="MAX_AR" :step="0.1" size="small" />
            </td>
          </tr>
          <tr>
            <td class="condition-header" width="60">OD</td>
            <td class="condition-content" style="padding-right: 15px">
              <el-slider v-model="filter.od" range :max="MAX_OD" :step="0.1" size="small" />
            </td>
          </tr>
          <tr>
            <td class="condition-header" width="60">HP</td>
            <td class="condition-content" style="padding-right: 15px">
              <el-slider v-model="filter.hp" range :max="MAX_HP" :step="0.1" size="small" />
            </td>
          </tr>
          <tr>
            <td class="condition-header" width="60">BPM</td>
            <td class="condition-content" style="padding-right: 15px">
              <el-slider v-model="filter.bpm" range :max="MAX_BPM" :step="1" size="small" />
            </td>
          </tr>
          <tr>
            <td class="condition-header" width="60">时长</td>
            <td class="condition-content" style="padding-right: 15px">
              <el-slider v-model="filter.length" range :max="MAX_LENGTH" :step="1" size="small" :format-tooltip="formatTime" />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div
      class="beatmapsets"
      v-infinite-scroll="loadMore"
      :infinite-scroll-disabled="!autoload"
      :infinite-scroll-immediate="false"
    >
      <el-row v-for="index in (Math.ceil(sets.length / 2) + 1)" :key="index" class="sets-row">
        <el-col
          :xs="{ span: 11, offset: 0 }"
          :sm="{ span: 11, offset: 0 }"
          :md="{ span: 11, offset: 0 }"
          class="sets-item"
        >
          <SongCard
            :BeatmapSet="sets[(index - 1) * 2]"
            v-if="sets[(index - 1) * 2]"
            @show-detail="showDetail"
          />
        </el-col>
        <el-col
          :xs="{ span: 11, offset: 0 }"
          :sm="{ span: 11, offset: 0 }"
          :md="{ span: 11, offset: 0 }"
          class="sets-item"
        >
          <SongCard
            :BeatmapSet="sets[(index - 1) * 2 + 1]"
            v-if="sets[(index - 1) * 2 + 1]"
            @show-detail="showDetail"
          />
        </el-col>
      </el-row>
      <!-- <el-button
        v-show="autoload"
        class="btn-load-more"
        :icon="'el-icon-arrow-down'"
        size="mini"
        round
        v-if="!no_more"
        @click="loadMore"
      >加载更多</el-button>-->
      <el-alert v-if="no_more" title="没有更多啦！" center show-icon type="info" :closable="false" />
    </div>
  </div>
  <Player />
  <el-dialog
    v-model="modalVisible"
    width="75%"
    :modal="true"
    :show-close="false"
    :destroy-on-close="true"
    :lock-scroll="true"
    :append-to-body="true"
    :center="true"
    custom-class="song-detail-modal"
  >
    <SongDetailModal :BeatmapSet="modalMap" :ActiveBid="modalBid"  v-if="modalMap" />
    <div
      class="modal-background"
      :style="{
        'background-image': `url(https://a.sayobot.cn/beatmaps/${modalMap?.id}/covers/cover.webp)`,
      }"
    ></div>
  </el-dialog>
</template>

<script lang="ts">
import { IBeatmapSet } from "@src/common/interfaces/osu";
import { IApiBeatmapSet, IBeatmapListParams, IBeatmapFilter } from "@src/common/interfaces/api.osu";

import SongCard from "@/components/SongCard.vue";
import Player from "@/components/Player.vue";

import SongDetailModal from "@/components/SongDetailModal.vue";
import { apiData2IBeatmapSet } from "@src/common/utils/data-trans";
import Api from "@src/common/utils/api";
import { onMounted, reactive, Ref, ref, watch } from "vue";
import { cloneDeep } from "lodash";
import store from "@src/common/utils/store";
import { OsuConstant } from "@src/common/constant";
import { ElInfiniteScroll } from "element-plus";

import { listenerLinkBeatmap } from "@src/render/hooks/protocol/ipc-renderer";

export default {
  name: "HomePage",
  components: { SongCard, Player, SongDetailModal },
  directives: { "infinite-scroll": ElInfiniteScroll },
  setup() {
    let sets: Ref<IBeatmapSet[]> = ref([]);
    let linksets: Ref<IBeatmapSet[]> = ref([]);
    let error = ref(false);
    let autoload = ref(false);
    let no_more = ref(false);
    let modalVisible = ref(false);
    let modalMap: Ref<IBeatmapSet | undefined> = ref(undefined);
    let modalBid: Ref<number | undefined> = ref(undefined);

    const MAX_STARS = 15;
    const MAX_CS = 10;
    const MAX_AR = 10;
    const MAX_OD = 10;
    const MAX_HP = 10;
    const MAX_BPM = 360;
    const MAX_LENGTH = 900;

    let keyword = ref("");
    if (store.has("searchKeyword")) {
      keyword.value = store.get("searchKeyword");
    }
    var filter: IBeatmapFilter = reactive({
      mode: [],
      approved: [],
      language: [],
      genre: [],
      stars: [0, MAX_STARS],
      cs: [0, MAX_CS],
      ar: [0, MAX_AR],
      od: [0, MAX_OD],
      hp: [0, MAX_HP],
      bpm: [0, MAX_BPM],
      length: [0, MAX_LENGTH],
    });
    if (store.has("searchFilter")) {
      const stored = store.get("searchFilter");
      // Migration for old [0, 0] values to full range
      if (stored.stars && stored.stars[1] === 0) stored.stars = [0, MAX_STARS];
      if (stored.cs && stored.cs[1] === 0) stored.cs = [0, MAX_CS];
      if (stored.ar && stored.ar[1] === 0) stored.ar = [0, MAX_AR];
      if (stored.od && stored.od[1] === 0) stored.od = [0, MAX_OD];
      if (stored.hp && stored.hp[1] === 0) stored.hp = [0, MAX_HP];
      if (stored.bpm && stored.bpm[1] === 0) stored.bpm = [0, MAX_BPM];
      if (stored.length && stored.length[1] === 0) stored.length = [0, MAX_LENGTH];

      filter = reactive(stored);
    }
    const limit = ref(20);
    let page = ref(0);
    const filterBtnClass = "filter-checkbox-btn";

    const isFilterArrayEmpty = (arr: any[] | undefined): boolean => {
      return arr?.length === 0;
    };

    const isFilterIgnored = (arr: [number, number] | undefined, max: number): boolean => {
      if (!arr) return true;
      if (arr[0] === 0 && arr[1] === 0) return true;
      if (arr[0] === 0 && arr[1] === max) return true;
      return false;
    };

    const isFilterEmpty = (): boolean => {
      let result = true;
      result &&= keyword.value.length === 0;
      result &&= filter.mode?.length === 0;
      result &&= filter.approved?.length === 0;
      result &&= filter.language?.length === 0;
      result &&= filter.genre?.length === 0;
      result &&= isFilterIgnored(filter.stars, MAX_STARS);
      result &&= isFilterIgnored(filter.cs, MAX_CS);
      result &&= isFilterIgnored(filter.ar, MAX_AR);
      result &&= isFilterIgnored(filter.od, MAX_OD);
      result &&= isFilterIgnored(filter.hp, MAX_HP);
      result &&= isFilterIgnored(filter.length, MAX_LENGTH);
      result &&= isFilterIgnored(filter.bpm, MAX_BPM);
      return result;
    };
    const onSearch = async () => {
      page.value = 0;
      sets.value = [];
      no_more.value = false;
      const try_convert = Number(keyword.value);
      if (!isNaN(try_convert)) {
        const result = await Api.get(`/v2/beatmapinfo?K=${try_convert}`);
        if (result && result.status === 200 && result.data.status === 0) {
          const data = result.data.data as IApiBeatmapSet;
          sets.value.push(apiData2IBeatmapSet(data));
        }
      }
      // 等第一页加载结束才启用自动滚动加载
      autoload.value = false;
      await loadMore();
      autoload.value = true;
      store.set("searchKeyword", keyword.value);
      store.set("searchFilter", filter);
    };

    const showDetail = (sid: number, bid: number | undefined = undefined) => {
      modalMap.value = [...sets.value, ...linksets.value].find(v => v.id === sid);
      if (bid) modalBid.value = bid;
      if (modalMap.value) {
        modalVisible.value = true;
      }
    };

    const handleLinkBeatmap = async (_: any, url: string) => {
      const uri = new URL(url);
      const [type] = uri.pathname.substr(1).split("/");
      switch (type) {
        case "beatmapsets": {
          const [_1, sid] = uri.pathname.substr(1).split("/");
          const [_2, bid] = uri.hash.split("/");
          if (!sid) break;
          const info = await Api.get(`/v2/beatmapinfo?K=${sid}`);
          if (!info || info.status !== 200) {
            error.value = true;
            return;
          }
          const beatmapset = info.data.data as IApiBeatmapSet;
          linksets.value.push(apiData2IBeatmapSet(beatmapset));
          showDetail(Number(sid), bid ? Number(bid) : undefined);
          break;
        }
        default:
          break;
      }
    };

    const combineFilterObj = (): IBeatmapListParams => {
      let obj: IBeatmapListParams = {
        cmd: "beatmaplist",
        limit: limit.value,
        offset: limit.value * (page.value - 1),
        type: isFilterEmpty() ? "hot" : "search",
      };
      if (keyword.value && keyword.value?.trim().length !== 0)
        obj.keyword = keyword.value?.trim();
      if (!isFilterArrayEmpty(filter.mode))
        obj.mode = filter.mode?.reduce(
          (sum: number, num: number) => (sum += num),
          0
        );
      if (!isFilterArrayEmpty(filter.approved))
        obj.class = filter.approved?.reduce(
          (sum: number, num: number) => (sum += num),
          0
        );
      if (!isFilterArrayEmpty(filter.genre))
        obj.genre = filter.genre?.reduce(
          (sum: number, num: number) => (sum += num),
          0
        );
      if (!isFilterArrayEmpty(filter.language))
        obj.language = filter.language?.reduce(
          (sum: number, num: number) => (sum += num),
          0
        );
      if (!isFilterIgnored(filter.stars, MAX_STARS)) obj.stars = filter.stars;
      if (!isFilterIgnored(filter.ar, MAX_AR)) obj.ar = filter.ar;
      if (!isFilterIgnored(filter.cs, MAX_CS)) obj.cs = filter.cs;
      if (!isFilterIgnored(filter.hp, MAX_HP)) obj.hp = filter.hp;
      if (!isFilterIgnored(filter.od, MAX_OD)) obj.od = filter.od;
      if (!isFilterIgnored(filter.bpm, MAX_BPM)) obj.bpm = filter.bpm;
      if (!isFilterIgnored(filter.length, MAX_LENGTH)) obj.length = filter.length;
      return obj;
    };

    const loadMore = async () => {
      if (no_more.value) return;
      page.value++;
      const result = await Api.post("/?post", combineFilterObj());
      if (!result || result.status !== 200 || result.data.status !== 0) {
        error.value = true;
        return;
      }
      for (var i = 0; i < result.data.data.length; ++i) {
        const sid = result.data.data[i].sid;
        if (sets.value.findIndex(v => v.id === sid) !== -1) continue;
        const info = await Api.get(`/v2/beatmapinfo?K=${sid}`);
        if (!info || info.status !== 200) {
          error.value = true;
          return;
        }
        const beatmapset = info.data.data as IApiBeatmapSet;
        sets.value.push(apiData2IBeatmapSet(beatmapset));
      }
      if (sets.value.length >= result.data.results) {
        no_more.value = true;
        // console.log('no more')
      }
    };

    const formatTime = (val: number) => {
      const m = Math.floor(val / 60);
      const s = val % 60;
      return `${m}:${s < 10 ? '0' + s : s}`;
    };

    onMounted(async () => {
      await onSearch();
      autoload.value = true;
    });

    watch(
      () => cloneDeep(filter),
      (filter, _) => {
        onSearch();
      }
    );

    listenerLinkBeatmap(handleLinkBeatmap);

    return {
      // data
      sets,
      error,
      filter,
      keyword,
      autoload,
      no_more,
      modalMap,
      modalVisible,
      modalBid,
      MAX_STARS,
      MAX_CS,
      MAX_AR,
      MAX_OD,
      MAX_HP,
      MAX_BPM,
      MAX_LENGTH,
      // methods
      showDetail,
      onSearch,
      loadMore,
      formatTime,
      // constants
      filterBtnClass,
      modeOptions: OsuConstant.mode,
      approvedOptions: OsuConstant.approved,
      genreOptions: OsuConstant.genre,
      languageOptions: OsuConstant.language,
    };
  }
};
</script>

<style lang="less">
.home {
  min-height: 100vh;
  padding: 10px 8px;

  .beatmap-filter {
    padding: 6px 16px;
    position: relative;
    margin-bottom: 10px;

    .beatmap-filter-background {
      position: absolute;
      top: 0;
      left: 0;
      height: 100%;
      width: 100%;
      background-position: 50%;
      background-repeat: no-repeat;
      background-size: cover;
      opacity: 0.5;
      filter: blur(5px);
    }

    .conditions {
      color: rgba(255, 255, 255, 0.85);
      margin-top: 10px;

      .condition-header {
        text-align: right;
        padding: 0 7px;
      }

      .condition-content {
        text-align: left;
        padding: 2px 7px;

        .filter-checkbox-btn {
          &.is-checked {
            &:first-child .el-checkbox-button__inner {
              border-left-color: hsl(200, 100%, 60%);
            }

            .el-checkbox-button__inner {
              background: hsl(200, 100%, 60%);
              border-color: hsl(200, 100%, 60%);
            }
          }

          .el-checkbox-button__inner {
            background: rgba(73, 83, 96, 0.7);
            color: hsl(200, 40%, 100%);
          }
        }
      }
    }

    .conditions-advanced {
      width: 100%;
    }
  }

  .beatmapsets {
    width: 100%;
    min-height: calc(100vh - 500px);
    margin-bottom: 40px;

    .sets-row {
      margin-bottom: 16px;
      width: 100%;
      justify-content: space-evenly;
    }

    .btn-load-more {
      background: rgba(73, 83, 96, 0.7);
      color: hsl(200, 40%, 100%);
    }
  }
}

.sets-item {
  margin-right: 8px;
}
</style>
