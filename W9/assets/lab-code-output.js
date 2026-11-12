/* Code / Output tabs and per-state speaker Notes for the W9 Lab. */
(() => {
  if (window.__w9CodeOutputTabs) return;
  window.__w9CodeOutputTabs = true;

  const groupSelector = '.w9-code-output-tabs';
  const slideSelector = '.w9-tabbed-lab-slide';
  const triggerSelector = '.w9-tab-view-trigger, .w9-code-output-trigger';
  const tabFragment = button => button.dataset.w9Tab === 'output' ? 0 : -1;
  let reveal;

  const fragmentFor = group => Math.max(-1, ...[...group.querySelectorAll(triggerSelector)]
    .filter(trigger => trigger.classList.contains('visible'))
    .map(trigger => Number(trigger.dataset.fragmentIndex))
    .filter(Number.isFinite));

  const stateFor = slide => {
    const group = slide?.querySelector(groupSelector);
    if (!group) return null;
    const fragment = fragmentFor(group);
    return fragment < 0 ? 'code' : `output-${fragment}`;
  };

  const templateFor = (slide, state = stateFor(slide)) => state
    ? slide?.querySelector(`template[data-w9-notes-state="${state}"]`)
    : null;

  const syncNotes = (slide, state) => {
    const template = templateFor(slide, state);
    // Student slides have neither templates nor Notes. Never create Notes there.
    if (!template) return;
    let notes = slide.querySelector(':scope > aside.notes');
    if (!notes) {
      notes = document.createElement('aside');
      notes.className = 'notes';
      slide.appendChild(notes);
    }
    if (notes.innerHTML !== template.innerHTML) notes.innerHTML = template.innerHTML;
    notes.dataset.w9NotesState = state;
  };

  const syncGroup = group => {
    const fragment = fragmentFor(group);
    const state = fragment < 0 ? 'code' : `output-${fragment}`;
    const tab = fragment < 0 ? 'code' : 'output';
    const buttons = [...group.querySelectorAll('[data-w9-tab]')];
    const active = buttons.find(button => button.dataset.w9Tab === tab) ?? buttons[0];
    buttons.forEach(button => {
      const selected = button === active;
      button.setAttribute('aria-selected', String(selected));
      button.tabIndex = selected ? 0 : -1;
    });
    group.querySelectorAll('[role="tabpanel"]').forEach(panel => {
      panel.setAttribute('aria-hidden', String(panel.id !== active?.getAttribute('aria-controls')));
    });
    group.querySelectorAll('.w9-tab-view[data-w9-state]').forEach(view => {
      const selected = view.dataset.w9State === state;
      view.hidden = !selected;
      view.setAttribute('aria-hidden', String(!selected));
      view.classList.toggle('w9-tab-view-active', selected);
    });
    group.dataset.w9ActiveState = state;
    const slide = group.closest(slideSelector);
    if (slide) {
      slide.dataset.w9ActiveState = state;
      syncNotes(slide, state);
    }
  };

  const sync = () => document.querySelectorAll(groupSelector).forEach(syncGroup);

  const choose = (button, moveFocus = false) => {
    const group = button.closest(groupSelector);
    const slide = group?.closest('section');
    if (!slide || !reveal) return;
    const {h, v} = reveal.getIndices(slide);
    // Code is before the first fragment; Output starts with its first view.
    reveal.slide(h, v, tabFragment(button));
    sync();
    if (moveFocus) button.focus();
  };

  document.addEventListener('click', event => {
    const button = event.target.closest?.(`${groupSelector} [data-w9-tab]`);
    if (!button) return;
    event.preventDefault();
    event.stopPropagation();
    choose(button);
    // Next/Space after a mouse click should navigate Reveal, not reactivate a tab.
    button.blur();
  });

  document.addEventListener('keydown', event => {
    const button = event.target.closest?.(`${groupSelector} [data-w9-tab]`);
    if (!button) return;
    const buttons = [...button.closest(groupSelector).querySelectorAll('[data-w9-tab]')];
    const index = buttons.indexOf(button);
    let target;
    if (event.key === 'ArrowLeft') target = buttons[Math.max(0, index - 1)];
    else if (event.key === 'ArrowRight') target = buttons[Math.min(buttons.length - 1, index + 1)];
    else if (event.key === 'Home') target = buttons[0];
    else if (event.key === 'End') target = buttons[buttons.length - 1];
    else if (event.key === 'Enter' || event.key === ' ') target = button;
    else return;
    event.preventDefault();
    event.stopImmediatePropagation();
    choose(target, true);
  }, true);

  let attempts = 0;
  const bind = () => {
    if (!document.querySelector(groupSelector)) return;
    reveal = window.Reveal;
    const wrapper = reveal?.getRevealElement?.();
    if (!wrapper) {
      if (++attempts < 200) setTimeout(bind, 50);
      return;
    }

    const originalGetSlideNotes = reveal.getSlideNotes.bind(reveal);
    reveal.getSlideNotes = slide => {
      const target = slide ?? reveal.getCurrentSlide();
      if (target?.matches(slideSelector)) {
        const template = templateFor(target);
        if (template) return template.innerHTML;
      }
      return originalGetSlideNotes(target);
    };

    // The native notes plugin reads aside.notes directly. Capture runs before
    // its bubble listeners, even when the S window was opened before this hook.
    // Deriving state from Reveal's visible triggers avoids a Notes/event race.
    ['ready', 'slidechanged', 'fragmentshown', 'fragmenthidden'].forEach(name => {
      wrapper.addEventListener(name, sync, true);
    });
    sync();
  };

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', bind, {once: true});
  else bind();
})();
