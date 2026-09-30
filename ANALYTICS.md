# Lead conversion tracking

The existing Google tag uses `G-2H6S8FJNXS` (Prepared Landing Page property).
All seven Typeform embeds now call `preparedLeadSubmitted` through the official
`data-tf-on-submit` success callback. Starting, opening or abandoning a form does
not count. Repeated callbacks for the same response within the page count once.

The event is `generate_lead`, already enabled as a key event in Prepared's GA4
property. Its parameters identify this site, Typeform and the form ID. No contact
fields or Typeform response ID are sent to Google.

The extra placeholder Google tag has been removed. The availability counter now
uses the same confirmed-success signal instead of arbitrary window messages.

Test: `node --test lead-tracking.test.cjs`.

After deployment to the existing Netlify site, confirm the public source includes
`lead-tracking.js` and the callback on each embed. Observe a real successful form
submission in GA4 Realtime and reconcile with Typeform responses; do not submit
fake customer leads in production. No live deployment is implied by local tests.

Typeform's callback contract:
https://developer.typeform.com/developers/embed/callbacks/
