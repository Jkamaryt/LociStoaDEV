/* LociStoa mini engine: a tiny template engine (about 100 lines, no framework).
 *
 * The screens in index.html are written as a template with three special things:
 *   {{ name }}                         a blank filled in with a value from app.view()
 *   <ls-if test="isHome"> ... </ls-if>  only shown when the value is true
 *   <ls-for each="tabs" as="t"> ...     repeated once for every item in a list
 *   @click="t.go"  @input="onQuery"     run a function from app.view() on click / typing
 *
 * Every time the app's state changes, the engine builds the page again from the
 * template and uses the morphdom library to update only the parts that changed.
 */
"use strict";

class MiniApp {
  // Change part of the state, then redraw.
  setState(patch) {
    this.state = Object.assign({}, this.state, patch);
    if (this.redraw) this.redraw();
  }
}

const Engine = (() => {
  const BLANK = /\{\{\s*([^}]+?)\s*\}\}/g;

  // Look up "a.b.c" in the current values.
  function lookup(scope, path) {
    if (path === "true") return true;
    if (path === "false") return false;
    let value = scope;
    for (const key of path.split(".")) {
      if (value == null) return undefined;
      value = value[key];
    }
    return value;
  }

  function fill(text, scope) {
    return text.replace(BLANK, (_, path) => {
      const v = lookup(scope, path);
      return v == null ? "" : String(v);
    });
  }

  // Build real page elements from one template node. `key` keeps ids unique.
  function build(node, scope, parent, key, keyed) {
    if (node.nodeType === Node.TEXT_NODE) {
      parent.appendChild(document.createTextNode(fill(node.nodeValue, scope)));
      return;
    }
    if (node.nodeType !== Node.ELEMENT_NODE) return;

    if (node.localName === "ls-if") {
      if (lookup(scope, node.getAttribute("test"))) buildChildren(node, scope, parent, key + "i" + node.__n, true);
      return;
    }
    if (node.localName === "ls-for") {
      const items = lookup(scope, node.getAttribute("each")) || [];
      const name = node.getAttribute("as");
      items.forEach((item, index) => {
        const inner = Object.create(scope);
        inner[name] = item;
        buildChildren(node, inner, parent, key + "f" + node.__n + "_" + index, false);
      });
      return;
    }

    const el = node.cloneNode(false);
    for (const attr of Array.from(node.attributes)) {
      const name = attr.name;
      if (name[0] === "@") {                       // event handler
        el.removeAttribute(name);
        (el.__on = el.__on || {})[name.slice(1)] = lookup(scope, attr.value);
      } else if (name === "ls-ref") {              // function that receives the element
        el.__ref = lookup(scope, attr.value);
        el.setAttribute("ls-ref", "");
      } else if (attr.value.indexOf("{{") !== -1) {
        const whole = attr.value.match(/^\{\{\s*([^}]+?)\s*\}\}$/);
        const v = whole ? lookup(scope, whole[1]) : fill(attr.value, scope);
        if (v == null) el.removeAttribute(name); else el.setAttribute(name, String(v));
      }
    }
    // An id per <ls-if> block, so a new screen is drawn fresh instead of reusing the old one.
    if (keyed && !el.id) el.id = key;
    buildChildren(node, scope, el, key, false);
    parent.appendChild(el);
  }

  function buildChildren(node, scope, parent, key, keyed) {
    let n = 0;
    for (const child of Array.from(node.childNodes)) {
      build(child, scope, parent, keyed ? key + "-" + n++ : key, keyed);
    }
  }

  // Number every <ls-if>/<ls-for> once so their ids stay the same between redraws.
  function number(root) {
    let n = 0;
    root.querySelectorAll("ls-if, ls-for").forEach((el) => { el.__n = n++; });
  }

  function mount(app, template, root) {
    number(template.content);
    let queued = false;

    function draw() {
      queued = false;
      const next = document.createElement("div");
      buildChildren(template.content, app.view(), next, "", false);
      morphdom(root, next, {
        childrenOnly: true,
        onBeforeElUpdated(from, to) {            // keep the newest handlers on elements that stay
          from.__on = to.__on;
          from.__ref = to.__ref;
          return true;
        }
      });
      root.querySelectorAll("[ls-ref]").forEach((el) => { if (el.__ref) el.__ref(el); });
      if (app.onUpdate) app.onUpdate();
    }

    // Several state changes in a row cause one redraw.
    app.redraw = () => {
      if (!queued) { queued = true; queueMicrotask(draw); }
    };

    // One listener per event type for the whole app.
    ["click", "input", "keydown"].forEach((type) => {
      root.addEventListener(type, (event) => {
        for (let el = event.target; el && el !== root; el = el.parentNode) {
          if (el.__on && typeof el.__on[type] === "function") el.__on[type](event);
        }
      });
    });

    draw();
  }

  return { mount };
})();
