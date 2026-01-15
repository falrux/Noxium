AOS.init({
    duration: 800,
    easing: 'ease-in-out-back',
    once: false,
    offset: 120,
    delay: 100
});

feather.replace();

const mainContent = document.getElementById('main-content');
mainContent.style.transform = 'translateY(60px)';
mainContent.style.opacity = '0';

function smoothScrollEffects() {
    const scrollY = window.scrollY;
    const header = document.querySelector('header');
    const title = document.getElementById('main-title');
    const bgLogo = document.getElementById('background-logo');

    const parallaxSpeed = 0.5;
    bgLogo.style.transform = `translateY(${scrollY * parallaxSpeed}px) scale(${1 + scrollY * 0.0002})`;
    bgLogo.style.opacity = Math.max(0.05, 0.2 - scrollY * 0.0002);

    const headerScale = Math.max(0.5, 1 - scrollY * 0.002);
    header.style.transform = `scale(${headerScale}) translateY(${scrollY * 0.15}px)`;
    header.style.opacity = Math.max(0, 1 - scrollY * 0.003);

    const glowIntensity = Math.max(0.2, 0.8 - scrollY * 0.001);
    const glowSize = 10 + scrollY * 0.05;
    title.style.textShadow = `0 0 ${glowSize}px rgba(255,255,255,${glowIntensity})`;

    if (scrollY > window.innerHeight * 0.25) {
        const p = Math.min(1, (scrollY - window.innerHeight * 0.25) / (window.innerHeight * 0.25));
        const eased = 1 - Math.pow(1 - p, 3);
        mainContent.style.transform = `translateY(${60 - eased * 60}px)`;
        mainContent.style.opacity = eased;
    } else {
        mainContent.style.transform = 'translateY(60px)';
        mainContent.style.opacity = '0';
    }

    const cards = document.querySelectorAll('.feature-card');
    cards.forEach(card => {
        const pos = card.getBoundingClientRect().top;
        const trigger = window.innerHeight * 0.8;

        if (pos < trigger) {
            card.style.transform = 'translateY(0) rotate(0deg)';
            card.style.opacity = '1';
        } else {
            card.style.transform = 'translateY(20px) rotate(1deg)';
            card.style.opacity = '0.6';
        }
    });
}

let scrollTick = false;
window.addEventListener('scroll', () => {
    if (!scrollTick) {
        requestAnimationFrame(() => {
            smoothScrollEffects();
            scrollTick = false;
        });
        scrollTick = true;
    }
});

smoothScrollEffects();

function typeWriter(element, text, speed = 100) {
    let index = 0;
    element.innerHTML = '';

    function next() {
        if (index < text.length) {
            element.innerHTML += text.charAt(index);
            index++;
            setTimeout(next, speed);
        }
    }
    next();
}

setTimeout(() => {
    typeWriter(document.getElementById('main-title'), 'Noxium', 150);
}, 500);

const floatCard = document.getElementById('floating-card');

if (floatCard) {
    document.addEventListener('mousemove', e => {
        const rotX = (window.innerWidth / 2 - e.clientX) / 25;
        const rotY = (window.innerHeight / 2 - e.clientY) / 25;

        floatCard.style.transform =
            `perspective(1000px) rotateY(${rotX}deg) rotateX(${rotY}deg) scale3d(1.02,1.02,1.02)`;

        floatCard.style.boxShadow = `${-rotX}px ${rotY}px 30px rgba(255,255,255,0.2)`;
    });

    floatCard.innerHTML = `
        <img src="https://mdayspa.com/wp-content/uploads/2014/06/placeholder_image1.png"
             alt="Noxium Screenshot Placeholder"
             class="max-w-full max-h-80 object-contain rounded-lg block transition-transform duration-500">
    `;

    feather.replace();
}
