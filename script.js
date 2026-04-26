const withFamilyCheckbox = document.querySelector('#withFamily');
const familyBlock = document.querySelector('#familyBlock');
const familyList = document.querySelector('#familyList');
const addFamilyMemberButton = document.querySelector('#addFamilyMember');

function createFamilyItem() {
  const item = document.createElement('div');
  item.className = 'family-item';
  item.innerHTML = `
    <input type="text" name="familyName[]" placeholder="Имя и фамилия" />
    <input type="text" name="familyAge[]" placeholder="Возраст / комментарий" />
    <button type="button" aria-label="Удалить члена семьи">Удалить</button>
  `;

  const removeButton = item.querySelector('button');
  removeButton.addEventListener('click', () => item.remove());

  return item;
}

withFamilyCheckbox?.addEventListener('change', () => {
  familyBlock.classList.toggle('hidden', !withFamilyCheckbox.checked);

  if (withFamilyCheckbox.checked && familyList.children.length === 0) {
    familyList.appendChild(createFamilyItem());
  }
});

addFamilyMemberButton?.addEventListener('click', () => {
  familyList.appendChild(createFamilyItem());
});
