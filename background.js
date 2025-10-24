/**
 * @file background.js
 * @description Background script for the extension. Its primary role is to listen for tab updates
 * and inject the content script into YouTube and YouTube Music pages when they load.
 */

const ext = (typeof browser !== 'undefined') ? browser : chrome;

ext.runtime.onInstalled.addListener(() => {
  console.log("MPRIS Fixer extension has been successfully installed or updated.");
});
