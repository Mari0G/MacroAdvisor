const assert = require('assert');
const { spawn } = require('child_process');
const vm = require('vm');
const path = require('path');

const serverPath = path.join(__dirname, 'serve_prototype.js');
const child = spawn(process.execPath, [serverPath], {
  env: { ...process.env, PROTOTYPE_NO_BROWSER: '1' },
  stdio: ['ignore', 'pipe', 'inherit'],
});

async function serverUrl() {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error('Server start timed out.')), 3000);
    child.once('exit', (code) => reject(new Error(`Server exited with ${code}.`)));
    child.stdout.on('data', (chunk) => {
      const match = String(chunk).match(/PROTOTYPE_URL=(\S+)/);
      if (!match) return;
      clearTimeout(timer);
      resolve(match[1]);
    });
  });
}

async function main() {
  const url = await serverUrl();
  const htmlResponse = await fetch(url);
  const html = await htmlResponse.text();
  const styleMatch = html.match(/<style>([\s\S]*?)<\/style>/);
  const scriptMatch = html.match(
    /<script id="prototype-script-source">([\s\S]*?)<\/script>/,
  );

  assert.equal(htmlResponse.headers.get('content-type'), 'text/html; charset=utf-8');
  assert.ok(styleMatch, 'Inline CSS is missing.');
  assert.ok(scriptMatch, 'Executable inline JavaScript is missing.');
  assert.match(styleMatch[1], /\.phone\{/);
  assert.doesNotMatch(html, /type="text\/plain"/);
  assert.doesNotMatch(html, /src="\/prototype\.js"/);
  const script = scriptMatch[1];

  const elements = {};
  const listeners = {};
  const paletteButtons = ['lime', 'ocean', 'coral', 'violet'].map((palette) => ({
    dataset: { palette },
    classList: { toggle() {} },
    setAttribute() {},
  }));
  const document = {
    body: { dataset: {} },
    activeElement: { tagName: 'BODY', isContentEditable: false },
    querySelector(selector) {
      elements[selector] ||= {
        dataset: {},
        innerHTML: '',
        textContent: '',
        onclick: null,
      };
      return elements[selector];
    },
    querySelectorAll(selector) {
      return selector === '[data-palette]' ? paletteButtons : [];
    },
    addEventListener(event, callback) {
      listeners[event] = callback;
    },
  };
  const context = {
    URL,
    URLSearchParams,
    alert() {},
    document,
    history: { replaceState() {} },
    location: { href: url, search: '?variant=A' },
    setTimeout(callback) { callback(); },
  };
  vm.runInNewContext(script, context);

  assert.match(elements['#app'].innerHTML, /Heute/);
  assert.doesNotMatch(elements['#app'].innerHTML, /Prototyp wird geladen/);
  assert.equal(elements['#variantLabel'].textContent, 'A · Ruhig & klar');
  elements['#next'].onclick();
  assert.equal(document.body.dataset.v, 'B');
  assert.equal(elements['#variantLabel'].textContent, 'B · Editorial & warm');
  elements['#next'].onclick();
  assert.equal(document.body.dataset.v, 'C');
  listeners.click({
    target: {
      closest(selector) {
        return selector === '[data-palette]' ? paletteButtons[1] : null;
      },
    },
  });
  assert.equal(document.body.dataset.palette, 'ocean');
  process.stdout.write(
    `PASS ${url} rendered Today, switched A → B → C, and selected Ocean\n`,
  );
}

main()
  .catch((error) => {
    process.stderr.write(`${error.stack}\n`);
    process.exitCode = 1;
  })
  .finally(() => child.kill());
