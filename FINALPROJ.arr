use context starter2024

include image
include reactors

# Screen dimensions
WIDTH = 800
HEIGHT = 600

# Game constants defining movement, speed, and collision properties
CAR_MOVE = 10
TRUCK_SPEED = 6
COLLISION_DISTANCE = 50
TRUCK_MIN_DISTANCE = 70
CAR_SIZE = 50
OVERLAP_THRESHOLD = 10

# URLs for images
CAR_URL = "https://code.pyret.org/shared-image-contents?sharedImageId=1MWZLrq-EMOceQH-4omWIZV32B2D8K-mX"
TRUCK1_URL = "https://code.pyret.org/shared-image-contents?sharedImageId=1Tz5uVDLPPMQNRdHZgmULKLZuI46lV_PF"
TRUCK2_URL = "https://code.pyret.org/shared-image-contents?sharedImageId=1Tz5uVDLPPMQNRdHZgmULKLZuI46lV_PF"
TRUCK3_URL = "https://code.pyret.org/shared-image-contents?sharedImageId=1Tz5uVDLPPMQNRdHZgmULKLZuI46lV_PF"

# Load the images
CAR = image-url(CAR_URL)
TRUCK1 = image-url(TRUCK1_URL)
TRUCK2 = image-url(TRUCK2_URL)
TRUCK3 = image-url(TRUCK3_URL)
# Truck image dimensions for calculations (fixed at 50x50)
TRUCK_WIDTH = 50
TRUCK_HEIGHT = 50

# Data structure for holding position information
data Posn:
  | posn(x :: Number, y :: Number)
end

# World structure 
data World:
  | world(car :: Posn, truck1 :: Posn, truck2 :: Posn, truck3 :: Posn)
end

# Random x position generator for placing obstacles
fun random-x() -> Number:
  random(WIDTH - TRUCK_WIDTH)
end

# Random y position generator for placing obstacles
fun random-y() -> Number:
  random(HEIGHT - TRUCK_HEIGHT)
end

# distance function to use in collision later
fun distance(p1 :: Posn, p2 :: Posn) -> Number:
  num-sqrt(((p1.x - p2.x) * (p1.x - p2.x)) + ((p1.y - p2.y) * (p1.y - p2.y)))
end

fun random-truck(car :: Posn, truck1 :: Posn, truck2 :: Posn) -> Posn:
  new-x = random-x()
  new-y = random-y()
  if ((new-x == car.x) and (new-y == car.y)) or
    (distance(posn(new-x, new-y), truck1) < TRUCK_MIN_DISTANCE) or
    (distance(posn(new-x, new-y), truck2) < TRUCK_MIN_DISTANCE) :
    random-truck(car, truck1, truck2)
  else:
    posn(new-x, new-y)
  end
end



# Initialize the car and trucks
INIT_CAR = posn(600, 300)
INIT_TRUCK1 = random-truck(INIT_CAR, INIT_CAR, INIT_CAR)
INIT_TRUCK2 = random-truck(INIT_CAR, INIT_TRUCK1, INIT_CAR)
INIT_TRUCK3 = random-truck(INIT_CAR, INIT_TRUCK1, INIT_TRUCK2)
INIT_WORLD = world(INIT_CAR, INIT_TRUCK1, INIT_TRUCK2, INIT_TRUCK3)

# Game tick handler to move trucks
fun on-tick(w :: World) -> World:
  fun move-truck(truck :: Posn) -> Posn:
    if truck.y > HEIGHT:
      posn(random-x(), 0)
    else:
      posn(truck.x, truck.y + TRUCK_SPEED)
    end
  end

  world(
    w.car,
    move-truck(w.truck1),
    move-truck(w.truck2),
    move-truck(w.truck3)
  )
end

# Key press handler to move the car
fun on-key(w :: World, key :: String) -> World:
  if (key == "up") and (w.car.y > 0):
    world(posn(w.car.x, w.car.y - CAR_MOVE), w.truck1, w.truck2, w.truck3)
  else if (key == "down") and (w.car.y < (HEIGHT - 50)):
    world(posn(w.car.x, w.car.y + CAR_MOVE), w.truck1, w.truck2, w.truck3)
  else if (key == "left") and (w.car.x > 0):
    world(posn(w.car.x - CAR_MOVE, w.car.y), w.truck1, w.truck2, w.truck3)
  else if (key == "right") and (w.car.x < (WIDTH - 50)):
    world(posn(w.car.x + CAR_MOVE, w.car.y), w.truck1, w.truck2, w.truck3)
  else:
    w
  end
end

COLLISION-THRESHOLD = 70 
fun are-overlapping(car :: Posn, truck :: Posn):
  distance(car, truck) < COLLISION-THRESHOLD
end
# Function to check for collisions 
fun check-collision(w :: World) -> Boolean:
  car-left = w.car.x
  car-right = w.car.x + CAR_SIZE
  car-top = w.car.y
  car-bottom = w.car.y + CAR_SIZE
  are-overlapping(w.car, w.truck1) or are-overlapping(w.car,w.truck2) or are-overlapping(w.car,w.truck3)
end

# Stop the game when a collision occurs
fun stop-when(w :: World) -> Boolean:
  check-collision(w)
end

# Function to render the game scene
fun render(w :: World) -> Image:
  place-image(CAR, w.car.x, w.car.y,
    place-image(TRUCK1, w.truck1.y, w.truck1.x,
      place-image(TRUCK2, w.truck2.y, w.truck2.x,
        place-image(TRUCK3, w.truck3.y, w.truck3.x, empty-color-scene(WIDTH, HEIGHT, 'grey')))) )
end

# Reactor definition, where we set up the game logic
anim = reactor:
  init: INIT_WORLD,
  on-tick: on-tick,
  on-key: on-key,
  to-draw: render,
  stop-when: stop-when
end

# Start the game 
interact(anim)

"GAME OVER"
