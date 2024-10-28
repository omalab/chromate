let clickCount = 0;

document.addEventListener('click', (event) => {
	clickCount++;
	createClickPoint(event.pageX, event.pageY, 'left-click', clickCount);
});

document.addEventListener('contextmenu', (event) => {
	event.preventDefault();
	clickCount++;
	createClickPoint(event.pageX, event.pageY, 'right-click', clickCount);
});

document.getElementById('interactive-button').addEventListener('click', (event) => {
	event.target.style.backgroundColor = 'green';
	event.target.textContent = 'Clicked!';
});

function createClickPoint(x, y, clickType, count) {
	const point = document.createElement('div');
	point.classList.add('click-point', clickType);
	point.style.left = `${x - 10}px`;
	point.style.top = `${y - 10}px`;
	point.textContent = count;
	document.body.appendChild(point);
}