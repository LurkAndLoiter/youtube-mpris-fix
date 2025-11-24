new MutationObserver(() => {
  const vids = document.querySelectorAll('video:not([data-ext-fixed])');
  for (let vid of vids) {
    vid.dataset.extFixed = "1";
    vid.addEventListener('loadeddata', () => vid.currentTime = vid.currentTime);
    // This is a firefox patch; firefox does not track seeked playback change
    // That means the MPRIS position will continue counting even when paused
    // play will forecably align the position when Playback state play occurs
    vid.addEventListener('play', () => vid.currentTime = vid.currentTime);
  }
}).observe(document.documentElement, { childList: true, subtree: true });
