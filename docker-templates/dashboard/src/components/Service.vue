<template>
  <component v-bind:is="component" :item="item"></component>
</template>

<script>
import Card from "./services/Card.vue";

export default {
  name: "Service",
  components: {
    Card,
  },
  props: {
    item: Object,
  },
  computed: {
    component() {
      const type = this.item.type || "Card";
      if (type == "Card") {
        return Card;
      }
      return () => import(`./services/${type}.vue`);
    },
  },
};
</script>
