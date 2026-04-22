const form = document.getElementById("rsvpForm");
const statusText = document.getElementById("status");
const withFamilyCheckbox = document.getElementById("withFamily");
const familyWrap = document.getElementById("familyWrap");
const familyList = document.getElementById("familyList");
const addFamilyMemberBtn = document.getElementById("addFamilyMember");
const searchResult = document.getElementById("searchResult");

const firstNameInput = document.getElementById("firstName");
const lastNameInput = document.getElementById("lastName");

function createFamilyMemberRow() {
  const row = document.createElement("div");
  row.className = "family-member";
  row.innerHTML = `
    <input type="text" class="fm-first" placeholder="Имя" />
    <input type="text" class="fm-last" placeholder="Фамилия" />
    <button type="button" class="remove-member">Удалить</button>
  `;

  row.querySelector(".remove-member").addEventListener("click", () => row.remove());
  return row;
}

withFamilyCheckbox.addEventListener("change", (e) => {
  familyWrap.classList.toggle("hidden", !e.target.checked);
  if (e.target.checked && familyList.children.length === 0) {
    familyList.appendChild(createFamilyMemberRow());
  }
});

addFamilyMemberBtn.addEventListener("click", () => {
  familyList.appendChild(createFamilyMemberRow());
});

let searchTimeout;

async function searchGuest() {
  const q = `${firstNameInput.value.trim()} ${lastNameInput.value.trim()}`.trim();
  if (q.length < 2) {
    searchResult.textContent = "";
    return;
  }

  try {
    const response = await fetch(`/api/guests/search?q=${encodeURIComponent(q)}`);
    const data = await response.json();

    if (data.matches?.length) {
      const guest = data.matches[0];
      searchResult.textContent = `Найдено в списке: ${guest.first_name} ${guest.last_name}`;
      searchResult.style.color = "#0d6a2e";
    } else {
      searchResult.textContent = "В списке не нашли — мы добавим вас автоматически после отправки.";
      searchResult.style.color = "#7e1f3d";
    }
  } catch (error) {
    searchResult.textContent = "Не удалось проверить список гостей.";
    searchResult.style.color = "#b02020";
  }
}

[firstNameInput, lastNameInput].forEach((input) => {
  input.addEventListener("input", () => {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(searchGuest, 300);
  });
});

form.addEventListener("submit", async (event) => {
  event.preventDefault();

  const familyMembers = [...familyList.querySelectorAll(".family-member")]
    .map((row) => ({
      first_name: row.querySelector(".fm-first")?.value?.trim() ?? "",
      last_name: row.querySelector(".fm-last")?.value?.trim() ?? "",
    }))
    .filter((member) => member.first_name && member.last_name);

  const payload = {
    primary_guest: {
      first_name: firstNameInput.value.trim(),
      last_name: lastNameInput.value.trim(),
    },
    family_members: withFamilyCheckbox.checked ? familyMembers : [],
    attendance: document.getElementById("attendance").value,
    transport: document.getElementById("transport").value,
    accommodation: document.getElementById("accommodation").value,
    dietary: document.getElementById("dietary").value.trim(),
    music: document.getElementById("music").value.trim(),
    arrival_time: document.getElementById("arrivalTime").value,
    comment: document.getElementById("comment").value.trim(),
  };

  statusText.textContent = "Отправляем...";
  statusText.style.color = "#7e1f3d";

  try {
    const response = await fetch("/api/rsvp", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });

    const data = await response.json();
    if (!response.ok) {
      throw new Error(data.error || "Ошибка отправки");
    }

    statusText.textContent = "Спасибо! Ваша анкета сохранена 💍";
    statusText.style.color = "#0d6a2e";
    form.reset();
    familyWrap.classList.add("hidden");
    familyList.innerHTML = "";
    searchResult.textContent = "";
  } catch (error) {
    statusText.textContent = `Не удалось отправить: ${error.message}`;
    statusText.style.color = "#b02020";
  }
});

const revealElements = document.querySelectorAll(".reveal");
const observer = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("visible");
      }
    });
  },
  { threshold: 0.18 },
);

revealElements.forEach((el) => observer.observe(el));
