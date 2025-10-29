let active = false;
let ytTabs = new Set();
function updateActive() {
  const wasActive = active;
  active = ytTabs.size > 0;
  if (active && !wasActive) {
    chrome.runtime.sendNativeMessage('mpris_helper', {action: 'start'});
  } else if (!active && wasActive) {
    chrome.runtime.sendNativeMessage('mpris_helper', {action: 'stop'});
  }
}
function checkTab(tab) {
  if (!tab?.url) return;
  const id = tab.id;
  const isYt = !!tab.url.match(/youtube.com/);
  const had = ytTabs.has(id);
  if (isYt && !had) ytTabs.add(id);
  else if (!isYt && had) ytTabs.delete(id);
  updateActive();
}
// on tab switch / window focus
function checkActive() {
  chrome.tabs.query({active: true, lastFocusedWindow: true}, ([tab]) => checkTab(tab));
}
// initial + updates
chrome.tabs.query({}, tabs => tabs.forEach(checkTab));
chrome.tabs.onActivated.addListener(checkActive);
chrome.tabs.onUpdated.addListener((id, change, tab) => {
  if (change.url || change.status === 'complete') checkTab(tab);
});
chrome.tabs.onRemoved.addListener(id => {
  if (ytTabs.has(id)) { ytTabs.delete(id); updateActive(); }
});
chrome.windows.onFocusChanged.addListener(checkActive);

chrome.runtime.onSuspend.addListener(() => {
  chrome.runtime.sendNativeMessage('mpris_helper', {action: 'stop'});
});
