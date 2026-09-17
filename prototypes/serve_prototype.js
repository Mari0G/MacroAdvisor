const http = require('http');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const host = '127.0.0.1';
const prototypePath = path.join(__dirname, 'macro_advisor_ui_prototype.html');
const browserCandidates = [
  'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',
  'C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe',
  'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
  'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe',
];

function prototypeSource() {
  return fs.readFileSync(prototypePath, 'utf8');
}

const server = http.createServer((request, response) => {
  if (request.url === '/favicon.ico') {
    response.writeHead(204);
    response.end();
    return;
  }

  response.writeHead(200, {
    'Content-Type': 'text/html; charset=utf-8',
    'Cache-Control': 'no-store',
  });
  response.end(prototypeSource());
});

function openBrowser(port) {
  const browser = browserCandidates.find((candidate) => fs.existsSync(candidate));
  if (!browser) throw new Error('Microsoft Edge or Google Chrome was not found.');

  const child = spawn(browser, ['--new-window', `http://${host}:${port}/?variant=A`], {
    detached: true,
    stdio: 'ignore',
  });
  child.unref();
}

server.on('error', (error) => {
  throw error;
});

const requestedPort = Number(process.env.PROTOTYPE_PORT || 0);
server.listen(requestedPort, host, () => {
  const address = server.address();
  if (typeof address === 'string' || address == null) {
    throw new Error('Prototype server did not receive a TCP port.');
  }
  const url = `http://${host}:${address.port}/?variant=A`;
  process.stdout.write(`PROTOTYPE_URL=${url}\n`);
  if (process.env.PROTOTYPE_NO_BROWSER !== '1') openBrowser(address.port);
});
