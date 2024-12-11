<script setup>
  import { ref, reactive, computed } from 'vue'

  import { fetch } from '../rails'
  import { extract_bandcamp_details_path } from '../routes'

  import MoneyField from './MoneyField.vue'
  
  const props = defineProps(['album', 'tracks'])

  const album = reactive(props.album || {})
  const tracks = ref(props.tracks || [])

  const hidden = computed(() => tracks.value.map(t => t.track_number == null))

  async function loadDataFromBandcamp() {
    if (!album.bandcamp_url.match(/^(https?:\/\/)?([a-z0-9-]+\.)?bandcamp.com/)) return
    
    // fetch, virtual dom, extract parameters
    const res = await fetch(extract_bandcamp_details_path({url: album.bandcamp_url}), {method: "POST"})
    const params = await res.json()

    Object.assign(album, params.album)
    tracks.value = params.tracks
  }

  function makePrivateIfUnreleased() {
    if (!album.release_date) return
    album.private = new Date(album.release_date) > new Date()
  }

  function addTrack() {
    tracks.value.push({ track_number: tracks.value.length + 1 })
    renumberTracks()
  }

  function toggleHiddenTrackAt(index) {
    if (tracks.value[index].track_number) {
      tracks.value[index].track_number = null
    } else {
      tracks.value[index].track_number = index + 1
    }
    renumberTracks()
  }

  function removeTrackAt(index) {
    tracks.value.splice(index, 1)
    renumberTracks()
  }

  function renumberTracks() {
    let track_number = 1
    for (let idx in tracks.value) {
      if (tracks.value[idx].track_number) {
        tracks.value[idx].track_number = track_number
        track_number += 1
      }
    }
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

  <section class="section">
    <div class="field">
      <label class="label is-required">Bandcamp URL</label>
      <div class="control">
        <input class="input" name="album[bandcamp_url]" type="url" placeholder="https://theband.bandcamp.com/album/the-album" v-model="album.bandcamp_url" @change="loadDataFromBandcamp">
      </div>
      <p class="help">
        Populating this will autofill much of the form from Bandcamp.
      </p>
    </div>

    <div class="field">
      <label class="label is-required">Album Name</label>
      <div class="control">
        <input class="input" name="album[name]" type="text" v-model="album.name">
      </div>
    </div>

    <div class="field">
      <label class="label is-required">Artist Name</label>
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

    <img class="album-art" :src="album.album_art_url" v-if="album.album_art_url"/>

    <div class="field">
      <label class="label is-required">Release Date</label>
      <div class="control">
        <input class="input" name="album[release_date]" type="date" v-model="album.release_date" @change="makePrivateIfUnreleased">
      </div>
    </div>

    <!-- <div class="field">
      <label class="label">Catalog Number</label>
      <div class="control">
        <input class="input" name="album[catalog_number]" type="text" v-model="album.catalog_number" placeholder="ABC-001">
      </div>
    </div> -->

    <div class="field">
      <label class="label">UPCs</label>
      <div class="control">
        <input class="input" name="album[upcs]" type="tags" v-model="album.upcs" placeholder="0123456789000">
      </div>
      <p class="help">From DistroKid</p>
    </div>

    <div class="field">
      <div class="control">
        <label class="checkbox">
          <input type="checkbox" name="album[private]" v-model="album.private" />
          <span> Hidden</span>
        </label>
      </div>
      <p class="help">
        Visible to admins only. Useful for albums that are unreleased, have been taken down, or are no longer associated with the label.
      </p>
    </div>
  </section>


  <section class="section">
    <h2 class="is-size-3">Tracks</h2>

    <div v-for="(track, index) in tracks">
      <h4>
        <span>Track </span>
        <span v-if="track.track_number">{{ track.track_number }}</span>
        <span v-else>[Hidden]</span>
        <span>&nbsp;</span>
        <button @click.prevent="removeTrackAt(index)"><i class="ri-delete-bin-6-line"></i></button>
      </h4>

      <input type="hidden" name="album[tracks][][id]" v-model="track.id">
      <input type="hidden" name="album[tracks][][bandcamp_id]" v-model="track.bandcamp_id">
      <input type="hidden" name="album[tracks][][track_number]" v-model="track.track_number">

      <div class="field is-horizontal">
        <div class="field-label">
          <label class="label">Hidden</label>
        </div>
        <div class="field-body">
          <div class="field is-narrow">
            <div class="control">
              <label class="checkbox">
                <input type="checkbox" :checked="hidden[index]" @change="toggleHiddenTrackAt(index)" />
              </label>
            </div>
            <p class="help">
              Visible to admins only. Useful for tracks that have been taken down.
            </p>
          </div>
        </div>
      </div>

      <div class="field is-horizontal">
        <div class="field-label is-normal">
          <label class="label is-required">Name</label>
        </div>
        <div class="field-body">
          <div class="field">
            <div class="control">
              <input class="input" name="album[tracks][][name]" type="text" v-model="track.name" placeholder="Song name">
            </div>
          </div>
        </div>
      </div>

      <div class="field is-horizontal">
        <div class="field-label is-normal">
          <label class="label is-required">Bandcamp URL</label>
        </div>
        <div class="field-body">
          <div class="field">
            <div class="control">
              <input class="input" name="album[tracks][][bandcamp_url]" type="url" placeholder="https://theband.bandcamp.com/track/the-song" v-model="track.bandcamp_url">
            </div>
          </div>
        </div>
      </div>


      <div class="field is-horizontal">
        <div class="field-label is-normal">
          <label class="label is-required">ISRC</label>
        </div>
        <div class="field-body">
          <div class="field">
            <div class="control is-expanded">
              <input class="input" name="album[tracks][][isrc]" type="text" v-model="track.isrc" placeholder="QZZ123456789">
            </div>
            <p class="help">
              From DistroKid. This is necessary to attribute streaming revenue.
            </p>
          </div>
        </div>
      </div>

      <div class="field is-horizontal">
        <div class="field-label is-normal">
          <label class="label">Credits</label>
        </div>
        <div class="field-body">
          <div class="field">
            <div class="control">
              <textarea class="textarea" name="album[tracks][][credits]" v-model="track.credits"></textarea>
            </div>
          </div>
        </div>
      </div>

      <div class="field is-horizontal">
        <div class="field-label is-normal">
          <label class="label">Lyrics</label>
        </div>
        <div class="field-body">
          <div class="field">
            <div class="control">
              <textarea class="textarea" name="album[tracks][][lyrics]" v-model="track.lyrics"></textarea>
            </div>
          </div>
        </div>
      </div>
    </div><!-- v-for -->

    <button class="button" @click.prevent="addTrack">Add Track</button>
  </section>
</template>
