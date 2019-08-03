<template>
  <div id="app">
    <transition name="fade" mode="out-in">
      <router-view style="overflow: auto"/>
    </transition>
  </div>
</template>

<script>
export default {}
</script>


<style lang="scss">
* {
  margin: 0;
  padding: 0;
  font-size: 15px;
  box-sizing: border-box;
}
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  width: 100%;
  height: 100%;
  background: url("/img/fundo.png");
  background-position: center center;
  background-repeat: no-repeat;
  background-size: cover;
  overflow: hidden;
}

.fade-enter-active,
.fade-leave-active {
  transition-duration: 0.3s;
  transition-property: opacity;
  transition-timing-function: ease;
}

.fade-enter,
.fade-leave-active {
  opacity: 0
}
</style>
