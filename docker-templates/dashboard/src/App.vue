<template>
  <div
    id="app"
    v-if="config"
    :class="[
      `theme-${config.theme}`,
      isDark ? 'is-dark' : 'is-light',
    ]"
  >
    <DynamicTheme :themes="config.colors" />
    <div id="bighead">
        <div class="logo">
          <i v-if="config.icon" :class="config.icon"></i>
        </div>
        <div class="title">
          <h1>{{ config.title }}</h1>
        </div>

        <div class="options">
          <SearchInput
            class="navbar-item is-inline-block-mobile"
            @input="filterServices"
            @search-focus="showMenu = true"
            @search-open="navigateToFirstService"
            @search-cancel="filterServices"
          />

          <DarkMode @updated="isDark = $event" />
        </div>
    </div>

    <section id="main-section" class="section">
      <div v-cloak class="container">
        <div>
          <!-- Horizontal layout -->
          <div class="columns is-multiline">
            <template v-for="group in services">
              <h2 v-if="group.name" class="column is-full group-title">
                <i v-if="group.icon" :class="['fa-fw', group.icon]"></i>
                <div v-else-if="group.logo" class="group-logo media-left">
                  <figure class="image is-48x48">
                    <img :src="group.logo" :alt="`${group.name} logo`" />
                  </figure>
                </div>
                {{ group.name }}
              </h2>
              <Service
                v-for="(item, index) in group.items"
                :key="index"
                v-bind:item="item"
                :class="['column', `is-${12 / config.columns}`]"
              />
            </template>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script>
const jsyaml = require("js-yaml");
const merge = require("lodash.merge");

import Service from "./components/Service.vue";
import SearchInput from "./components/SearchInput.vue";
import DarkMode from "./components/DarkMode.vue";
import DynamicTheme from "./components/DynamicTheme.vue";

import defaultConfig from "./assets/defaults.yml";

export default {
  name: "App",
  components: {
    Service,
    SearchInput,
    DarkMode,
    DynamicTheme,
  },
  data: function () {
    return {
      config: null,
      services: null,
      offline: false,
      filter: "",
      isDark: null,
      showMenu: false,
    };
  },
  created: async function () {
    this.buildDashboard();
    window.onhashchange = this.buildDashboard;
  },
  methods: {
    buildDashboard: async function () {
      const defaults = jsyaml.load(defaultConfig);
      let config;
      try {
        config = await this.getConfig();
        const path =
          window.location.hash.substring(1) != ""
            ? window.location.hash.substring(1)
            : null;

        if (path) {
          let pathConfig = await this.getConfig(`assets/${path}.yml`); // the slash (/) is included in the pathname
          config = Object.assign(config, pathConfig);
        }
      } catch (error) {
        console.log(error);
        config = this.handleErrors("⚠️ Error loading configuration", error);
      }
      this.config = merge(defaults, config);
      this.services = this.config.services;
      document.title =
        this.config.documentTitle ||
        `${this.config.title} | ${this.config.subtitle}`;
      if (this.config.stylesheet) {
        let stylesheet = "";
        for (const file of this.config.stylesheet) {
          stylesheet += `@import "${file}";`;
        }
        this.createStylesheet(stylesheet);
      }
    },
    getConfig: function (path = "assets/config.yml") {
      return fetch(path).then((response) => {
        if (response.redirected) {
          // This allows to work with authentication proxies.
          window.location.href = response.url;
          return;
        }
        if (!response.ok) {
          throw Error(`${response.statusText}: ${response.body}`);
        }

        const that = this;
        return response
          .text()
          .then((body) => {
            return jsyaml.load(body);
          })
          .then(function (config) {
            if (config.externalConfig) {
              return that.getConfig(config.externalConfig);
            }
            return config;
          });
      });
    },
    matchesFilter: function (item) {
      return (
        item.name.toLowerCase().includes(this.filter) ||
        (item.subtitle && item.subtitle.toLowerCase().includes(this.filter)) ||
        (item.tag && item.tag.toLowerCase().includes(this.filter))
      );
    },
    navigateToFirstService: function (target) {
      try {
        const service = this.services[0].items[0];
        window.open(service.url, target || service.target || "_self");
      } catch (error) {
        console.warning("fail to open service");
      }
    },
    filterServices: function (filter) {
      this.filter = filter;

      if (!filter) {
        this.services = this.config.services;
        return;
      }

      const searchResultItems = [];
      for (const group of this.config.services) {
        for (const item of group.items) {
          if (this.matchesFilter(item)) {
            searchResultItems.push(item);
          }
        }
      }

      this.services = [
        {
          name: filter,
          icon: "fas fa-search",
          items: searchResultItems,
        },
      ];
    },
    handleErrors: function (title, content) {
      return {
        message: {
          title: title,
          style: "is-danger",
          content: content,
        },
      };
    },
    createStylesheet: function (css) {
      let style = document.createElement("style");
      style.appendChild(document.createTextNode(css));
      document.head.appendChild(style);
    },
  },
};
</script>
