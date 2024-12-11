<script setup>
  import { ref, reactive } from 'vue'

  import { fetch } from '../rails'
  import { extract_bandcamp_details_path } from '../routes'

  import MoneyField from './MoneyField.vue'
  
  const props = defineProps(['album'])

  const album = reactive(props.album)

  async function loadDataFromBandcamp() {
    if (!album.bandcamp_url.match(/^(https?:\/\/)?([a-z0-9-]+\.)?bandcamp.com/)) return
    
    // fetch, virtual dom, extract parameters
    const res = await fetch(extract_bandcamp_details_path({url: album.bandcamp_url}), {method: "POST"})
    const params = await res.json()

    Object.assign(album, params)
  }

  function makePrivateIfUnreleased() {
    if (!album.release_date) return
    album.private = new Date(album.release_date) > new Date()
  }
</script>

<style>
  .album-art {
    width: 100px;
  }
</style>

<!-- TODO: support single tracks -->

<!-- NOTE: assumes already in a form -->
<template>
  <div class="field">
    <label class="label">Bandcamp URL</label>
    <div class="control">
      <input class="input" name="album[bandcamp_url]" type="url" placeholder="https://theband.bandcamp.com/album/the-album" v-model="album.bandcamp_url" @change="loadDataFromBandcamp">
    </div>
  </div>

  <div class="field">
    <label class="label">Album Name</label>
    <div class="control">
      <input class="input" name="album[name]" type="text" v-model="album.name">
    </div>
  </div>

  <div class="field">
    <label class="label">Artist Name</label>
    <div class="control">
      <input class="input" name="album[artist_name]" type="text" v-model="album.artist_name">
    </div>
  </div>

  <input type="hidden" name="album[bandcamp_id]" v-model="album.bandcamp_id">

  <div class="field">
    <label class="label">Price on Bandcamp</label>
    <div class="control">
      <MoneyField v-model="album.bandcamp_price" name="album[bandcamp_price]" />
    </div>
  </div>

  <div class="field">
    <label class="label">Album Art URL</label>
    <div class="control">
      <input class="input" name="album[album_art_url]" type="text" v-model="album.album_art_url">
    </div>
  </div>

  <img class="album-art" v-bind:src="album.album_art_url" v-if="album.album_art_url"/>

  <div class="field">
    <label class="label">Release Date</label>
    <div class="control">
      <input class="input" name="album[release_date]" type="date" v-model="album.release_date" @change="makePrivateIfUnreleased">
    </div>
  </div>

  <div class="field">
    <label class="label">Catalog Number</label>
    <div class="control">
      <input class="input" name="album[catalog_number]" type="text" v-model="album.catalog_number" placeholder="ABC-001">
    </div>
  </div>

  <div class="field">
    <label class="label">UPCs</label>
    <div class="control">
      <input class="input" name="album[upcs]" type="tags" v-model="album.upcs" placeholder="0123456789000">
    </div>
  </div>

  <div class="field">
    <div class="control">
      <label class="checkbox">
        <input type="checkbox" name="album[private]" v-model="album.private" />
        <span> Hidden</span>
      </label>
    </div>
    <p class="help">
        Visible to admins only. Useful for unreleased albums or ones taken down.
      </p>
  </div>

  <!-- TODO: tracks -->
  
</template>
