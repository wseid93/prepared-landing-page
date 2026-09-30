(function () {
  'use strict';

  var submitted = new Set();

  // Called only by Typeform's confirmed-success onSubmit callback.
  window.preparedLeadSubmitted = function (submission) {
    if (!submission || typeof submission.formId !== 'string' ||
        typeof submission.responseId !== 'string' ||
        !submission.formId.trim() || !submission.responseId.trim()) return;

    var key = JSON.stringify([submission.formId, submission.responseId]);
    if (submitted.has(key)) return;

    // The existing Google tag queues events while its network script loads.
    if (typeof window.gtag !== 'function') return;
    window.gtag('event', 'generate_lead', {
      send_to: 'G-2H6S8FJNXS',
      lead_source: 'typeform',
      site: 'prepared-landing-page',
      form_id: submission.formId
    });
    submitted.add(key);
    window.dispatchEvent(new CustomEvent('prepared:lead-submitted'));
  };
})();
