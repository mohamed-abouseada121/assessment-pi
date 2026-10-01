document.addEventListener('DOMContentLoaded', () => {
  const hrCtaButton = document.getElementById('hr-cta-button');
  const hrModal = document.getElementById('hr-modal');
  const modalClose = document.getElementById('modal-close');
  const modalLoader = document.getElementById('modal-loader');
  const modalContent = document.getElementById('modal-content');
  const apiGreeting = document.getElementById('api-greeting');
  const apiCoreMessage = document.getElementById('api-core-message');
  const apiQuote = document.getElementById('api-quote');
  const rdsStatus = document.getElementById('rds-status');
  const systemStatusDot = document.getElementById('system-status-dot');
  const systemStatusText = document.getElementById('system-status-text');

  const reactionForm = document.getElementById('reaction-form');
  const reactionButtons = document.querySelectorAll('.btn-reaction');
  const senderNameInput = document.getElementById('sender-name');
  const senderNoteInput = document.getElementById('sender-note');
  const formFeedback = document.getElementById('form-feedback');

  let selectedReaction = 'Outstanding Setup! 🚀';

  const API_BASE = window.location.port === '80' || window.location.port === '' 
    ? '' 
    : 'http://localhost:8000';

  async function checkSystemHealth() {
    try {
      const res = await fetch(`${API_BASE}/health`);
      if (res.ok) {
        const data = await res.json();
        systemStatusDot.className = 'status-indicator live';
        systemStatusText.textContent = `Cloud API: Healthy (${data.database.engine})`;
      } else {
        throw new Error('API degraded');
      }
    } catch (err) {
      systemStatusDot.className = 'status-indicator';
      systemStatusDot.style.backgroundColor = '#f59e0b';
      systemStatusText.textContent = 'Cloud API: Connecting...';
    }
  }

  async function fetchHrMessage() {
    modalLoader.classList.remove('hidden');
    modalContent.classList.add('hidden');
    formFeedback.classList.add('hidden');

    try {
      const res = await fetch(`${API_BASE}/api/hr-message`);
      if (!res.ok) throw new Error('Failed to fetch message');
      const data = await res.json();

      apiGreeting.textContent = data.greeting;
      apiCoreMessage.textContent = data.core_message;
      apiQuote.textContent = `"${data.candidate_quote}"`;

      if (data.database_connected) {
        rdsStatus.textContent = 'Connected (Amazon RDS)';
        rdsStatus.className = 'telemetry-value status-online';
      } else {
        rdsStatus.textContent = 'Degraded / Local Mode';
        rdsStatus.className = 'telemetry-value';
        rdsStatus.style.color = '#f59e0b';
      }

      modalLoader.classList.add('hidden');
      modalContent.classList.remove('hidden');
    } catch (err) {
      modalLoader.innerHTML = `
        <p style="color:#ef4444; margin-bottom: 0.5rem;">⚠️ Could not communicate with backend API.</p>
        <p style="font-size:0.8rem; color:#9ca3af;">Ensure backend is running on port 8000 or behind reverse proxy.</p>
      `;
    }
  }

  reactionButtons.forEach((btn) => {
    btn.addEventListener('click', () => {
      reactionButtons.forEach((b) => b.classList.remove('active'));
      btn.classList.add('active');
      selectedReaction = btn.getAttribute('data-reaction');
    });
  });

  reactionForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const name = senderNameInput.value.trim();
    const note = senderNoteInput.value.trim();

    if (!name) return;

    const submitBtn = document.getElementById('btn-submit-reaction');
    submitBtn.disabled = true;
    submitBtn.textContent = 'Saving to RDS...';

    try {
      const res = await fetch(`${API_BASE}/api/reactions`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          sender_name: name,
          reaction_type: selectedReaction,
          note: note || undefined
        })
      });

      if (!res.ok) throw new Error('Failed to save reaction');
      formFeedback.textContent = '✅ Stored in PostgreSQL! Thank you for the note.';
      formFeedback.style.color = '#10b981';
      formFeedback.classList.remove('hidden');
      reactionForm.reset();
    } catch (err) {
      formFeedback.textContent = '⚠️ Could not record feedback into PostgreSQL.';
      formFeedback.style.color = '#ef4444';
      formFeedback.classList.remove('hidden');
    } finally {
      submitBtn.disabled = false;
      submitBtn.textContent = 'Submit to PostgreSQL';
    }
  });

  hrCtaButton.addEventListener('click', () => {
    hrModal.classList.remove('hidden');
    fetchHrMessage();
  });

  modalClose.addEventListener('click', () => {
    hrModal.classList.add('hidden');
  });

  window.addEventListener('click', (e) => {
    if (e.target === hrModal) {
      hrModal.classList.add('hidden');
    }
  });

  window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && !hrModal.classList.contains('hidden')) {
      hrModal.classList.add('hidden');
    }
  });

  checkSystemHealth();
});
