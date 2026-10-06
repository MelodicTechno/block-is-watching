(function () {
  'use strict';

  var KEYWORD = '正在观看';
  var HIDE_ATTR = 'data-hide-watching-count';
  var MAX_CONTAINER_TEXT = 40;

  function normalize(text) {
    return (text || '').replace(/\s+/g, '');
  }

  function pickContainer(node) {
    if (!node) return null;
    var el = node.nodeType === 1 ? node : node.parentElement;
    if (!el) return null;
    var candidate = el;
    var current = el;
    while (current && current !== document.body && current.parentElement) {
      if (normalize(current.textContent).length > MAX_CONTAINER_TEXT) break;
      candidate = current;
      current = current.parentElement;
    }
    return candidate;
  }

  function hideTarget(node) {
    var target = pickContainer(node);
    if (!target || target.hasAttribute(HIDE_ATTR)) return;
    target.setAttribute(HIDE_ATTR, '');
    target.style.setProperty('display', 'none', 'important');
  }

  function scan(root) {
    if (!root) return;
    var walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, {
      acceptNode: function (node) {
        return node.nodeValue && node.nodeValue.indexOf(KEYWORD) !== -1
          ? NodeFilter.FILTER_ACCEPT
          : NodeFilter.FILTER_REJECT;
      }
    });
    var node;
    while ((node = walker.nextNode())) {
      hideTarget(node);
    }
  }

  function handleAdded(node) {
    if (node.nodeType === 3) {
      if (node.nodeValue && node.nodeValue.indexOf(KEYWORD) !== -1) {
        hideTarget(node);
      }
    } else if (node.nodeType === 1) {
      scan(node);
    }
  }

  var observer = new MutationObserver(function (mutations) {
    for (var i = 0; i < mutations.length; i++) {
      var mutation = mutations[i];
      if (mutation.type === 'childList') {
        mutation.addedNodes.forEach(handleAdded);
      } else if (mutation.type === 'characterData') {
        if (mutation.target.nodeValue && mutation.target.nodeValue.indexOf(KEYWORD) !== -1) {
          hideTarget(mutation.target);
        }
      }
    }
  });

  observer.observe(document, {
    childList: true,
    subtree: true,
    characterData: true
  });

  scan(document);
  document.addEventListener('DOMContentLoaded', function () {
    scan(document);
  });
  window.addEventListener('load', function () {
    scan(document);
  });

  function onRouteChange() {
    scan(document);
  }

  ['pushState', 'replaceState'].forEach(function (name) {
    var original = history[name];
    history[name] = function () {
      var result = original.apply(this, arguments);
      window.setTimeout(onRouteChange, 0);
      return result;
    };
  });
  window.addEventListener('popstate', onRouteChange);
  window.addEventListener('hashchange', onRouteChange);
})();
