const { test } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { runInNewContext } = require('node:vm');

function setup(ready = true) {
  const calls = [];
  const events = [];
  const window = { dispatchEvent: event => events.push(event.type) };
  if (ready) window.gtag = (...args) => calls.push(args);
  runInNewContext(readFileSync(__dirname + '/lead-tracking.js', 'utf8'), {
    window, CustomEvent: class { constructor(type) { this.type = type; } }
  });
  return { window, calls, events };
}

test('confirmed success counts once across duplicate embed callbacks without contact data', () => {
  const { window, calls, events } = setup();
  const success = { formId: 'form-1', responseId: 'response-1', email: 'private@example.com' };
  window.preparedLeadSubmitted(success);
  window.preparedLeadSubmitted(success);
  assert.equal(calls.length, 1);
  assert.equal(calls[0][1], 'generate_lead');
  assert.deepEqual(JSON.parse(JSON.stringify(calls[0][2])), {
    send_to: 'G-2H6S8FJNXS', lead_source: 'typeform',
    site: 'prepared-landing-page', form_id: 'form-1'
  });
  assert.deepEqual(events, ['prepared:lead-submitted']);
  window.preparedLeadSubmitted({ formId: 'form-1', responseId: 'response-2' });
  assert.equal(calls.length, 2);
});

test('empty or malformed callbacks do not count', () => {
  const { window, calls, events } = setup();
  for (const value of [null, {}, { formId: 'form' }, { formId: ' ', responseId: 'r' },
    { formId: 'form', responseId: 1 }]) window.preparedLeadSubmitted(value);
  assert.equal(calls.length, 0);
  assert.equal(events.length, 0);
});

test('a missing tag does not mark a response as counted', () => {
  const { window, calls } = setup(false);
  const success = { formId: 'form', responseId: 'response' };
  window.preparedLeadSubmitted(success);
  window.gtag = (...args) => calls.push(args);
  window.preparedLeadSubmitted(success);
  assert.equal(calls.length, 1);
});

test('all live embeds use the success callback and only the real Google tag is configured', () => {
  const html = readFileSync(__dirname + '/index.html', 'utf8');
  const mounts = html.match(/<[^>]+data-tf-live=[^>]+>/g);
  assert.equal(mounts.length, 7);
  assert.ok(mounts.every(mount => mount.includes('data-tf-on-submit="preparedLeadSubmitted"')));
  assert.ok(html.indexOf('src="lead-tracking.js"') < html.indexOf('src="//embed.typeform.com'));
  assert.equal(html.includes('G-XXXXXXXXXX'), false);
});
