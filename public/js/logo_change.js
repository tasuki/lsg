document.addEventListener('DOMContentLoaded', function () {
  const logo = document.getElementById('site-logo');

  if (!logo) return;

  const normalLogo = '/public/lsg_logo.svg';
  const angryLogo = '/public/lsg_logo_angry.svg';

  setInterval(function () {
    const isAngry = logo.getAttribute('src') === angryLogo;

    if (isAngry) {
      if (Math.random() < 0.2) {
        logo.setAttribute('src', normalLogo);
      }
    } else {
      if (Math.random() < 0.01) {
        logo.setAttribute('src', angryLogo);
      }
    }
  }, 1000);
});
