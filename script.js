const withFamily = document.getElementById('withFamily');
const familySection = document.getElementById('familySection');
const familyList = document.getElementById('familyList');
const addRelative = document.getElementById('addRelative');
const form = document.getElementById('rsvpForm');
const message = document.getElementById('formMessage');

function createRelativeRow() {
  const row = document.createElement('div');
  row.className = 'family-item';
  row.innerHTML = `
    <input type="text" name="relative_name[]" placeholder="Имя и фамилия" />
    <input type="text" name="relative_note[]" placeholder="Возраст / комментарий" />
    <button type="button" class="remove">Удалить</button>
  `;

  row.querySelector('.remove').addEventListener('click', () => row.remove());
  return row;
}

withFamily.addEventListener('change', () => {
  familySection.classList.toggle('hidden', !withFamily.checked);

  if (withFamily.checked && familyList.children.length === 0) {
    familyList.appendChild(createRelativeRow());
  }
});

addRelative.addEventListener('click', () => {
  familyList.appendChild(createRelativeRow());
});

form.addEventListener('submit', (event) => {
  event.preventDefault();
  message.textContent = 'Спасибо! Анкета заполнена. Мы свяжемся с вами при необходимости.';
  form.reset();
  familySection.classList.add('hidden');
  familyList.innerHTML = '';
});
