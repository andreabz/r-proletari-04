// Inserisce icone sociali nella navbar
$(document).ready(function() {
  const icons = `
    <div class='social-icons'>
      <a href='https://github.com/andreabz/r-proletari-04' target='_blank'>
        <i class='fab fa-github' style='font-size: 24px;'></i>
      </a>
      <a href='https://it.linkedin.com/in/andreabazzano' target='_blank'>
        <i class='fab fa-linkedin' style='font-size: 24px;'></i>
      </a>
    </div>
  `;
  $('.navbar').append(icons);
});

