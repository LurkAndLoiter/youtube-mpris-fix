/**
 * @file content.js
 * @description Fixes YouTube/YouTube Music MPRIS metadata updates on video
 * load.
 */
const VERSION = 1.2;
console.log(`Youtube MPRIS Fixer: Content script loaded. Version ${VERSION}`);

let videoElement = null;

/**
 * Finds the main video element.
 * @returns {HTMLVideoElement|null}
 */
function findVideoElement() {
  const selectors = [ 'video', '.html5-main-video', '#movie_player video' ];
  for (const selector of selectors) {
    const element = document.querySelector(selector);
    if (element instanceof HTMLVideoElement)
      return element;
  }
  return null;
}

/**
 * Updates media session metadata.
 */
function updateMediaSession() {
  if (!('mediaSession' in navigator) || !videoElement) return;
  if (!isNaN(videoElement.duration)) {
    navigator.mediaSession.setPositionState({duration : videoElement.duration});
  }
}

/**
 * Attaches event listener to the video element. Ensures single attachment.
 */
function attachVideoListeners() {
  if (!videoElement || videoElement.dataset.listenersAttached)
    return;
  const masterListener = () => updateMediaSession();
  videoElement.addEventListener('durationchange', masterListener);
  videoElement.dataset.listenersAttached = 'true';
  console.log("MPRIS Fixer: Video event listeners attached.");
}

/**
 * Clears stale video element reference and re-initializes.
 */
function resetAndInitialize() {
  videoElement = null;
  initialize();
}

/**
 * Initializes the script, finding the video element and setting up listeners.
 */
function initialize() {
  videoElement = findVideoElement();
  if (videoElement) {
    console.log("Youtube MPRIS Fixer: Video element found. Initializing...");
    attachVideoListeners();
    updateMediaSession();
  } else {
    console.log("Youtube MPRIS Fixer: Video element not found. Retrying...");
    setTimeout(initialize, 1000);
  }
}

/**
 * Watches for DOM changes to detect video player additions or updates.
 */
const pageObserver = new MutationObserver((mutations) => {
  for (const mutation of mutations) {
    for (const node of mutation.addedNodes) {
      if (node.nodeType === 1 && (node.querySelector('video') ||
                                  node.matches('video, #movie_player'))) {
        console.log(
            "Youtube MPRIS Fixer: Video player detected in DOM change. Re-initializing.");
        resetAndInitialize();
        return;
      }
    }
    if (mutation.type === 'attributes' &&
        mutation.target.matches('#movie_player, .html5-video-player')) {
      console.log(
          "Youtube MPRIS Fixer: Player attribute change detected. Re-initializing.");
      resetAndInitialize();
      return;
    }
  }
});

pageObserver.observe(document.body, {
  childList : true,
  subtree : true,
  attributes : true,
  attributeFilter : [ 'class', 'src' ]
});

initialize();
