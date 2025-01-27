document.addEventListener('DOMContentLoaded', function () {
    const form = document.getElementById('invite-form');
    const spinner = document.getElementById('spinner');
    const inviteButton = document.getElementById('slack-invite-button');
    const responseMessage = document.getElementById('response-message');

    if (form) {
      form.addEventListener('submit', async function (event) {
        event.preventDefault();

        const email = document.getElementById('email').value;

        if (!email || !email.includes('@')) {
          document.getElementById('response-message').textContent =
            'Please enter a valid email address.';
          return;
        }

        // Disable the button while processing
        inviteButton.disabled = true;
        inviteButton.style.opacity = '0.5';
        responseMessage.textContent = ' ';
        responseMessage.textContent =
              'Sending invite...';

        const payload = {
          user: email,
          team_domain: "envoyproxy",
          badge_url: "envoy",
          badge_type: "basic",
          newsletter_checked: false,
        };

        try {
          const response = await fetch('https://communityinviter.com/api/basic-invite', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload),
          });

          const result = await response.json();

          if (response.ok) {
            responseMessage.textContent =
              'Invite sent successfully! Check your email.';
          } else {
            responseMessage.textContent =
              'Error: ' + ('Unable to send invite.');
          }
        } catch (error) {
          responseMessage.textContent =
            'Error: Could not connect to the server. Please try again later.';
        } finally {
          inviteButton.style.display = 'flex';
          // Re-enable the button after processing
          inviteButton.disabled = false;
          inviteButton.style.opacity = '1';
        }
      });
    } else {
      console.error("Form with id 'invite-form' not found.");
    }
  });
