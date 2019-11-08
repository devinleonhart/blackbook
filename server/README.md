# The Black Book Server

The Black Book's server-side components live here.

License: AGPLv3+

## Server API

The Black Book's server-side components present a JSON API.

### Errors

If an unexpected error occurs, the server will respond with a 500 Internal
Server Error status code and no body. Otherwise, the response will have an
`errors` field containing an array of the errors that occurred in response to
the request. For example, the response to an unauthenticated request would look
like this:

```
{
  errors: ["You need to sign in or sign up before continuing."],
}
```

### Authentication

All requests other than sign-in require sending a JWT alongside the request. To sign in and receive a JWT, use the endpoint `/auth`

TODO: figure out how to authenticate with `devise_token_auth`

### Users

Users are the people with access to the Black Book. Note that there is no API
to create or delete Users; these actions have to be carried out by a Black Book
administrator directly in the database.

#### show

Details the requested user's ID, display name, and avatar if present.

`GET /api/v1/users/{user ID}`

sample response:

```
{
  id: 2,
  display_name: "T. Just T.",
  avatar_url: "http://www.example.com/storage/t.jpg",
}
```

#### update

Change a User's avatar.

`PUT/PATCH /api/v1/users/{user ID}`

parameters:

* `avatar` (optional, file): The new avatar for this user.

response:

a list of properties of the User (structurally identical to `users#show`)

### Universes

Universes contain Locations and Characters. They have a single User as an owner
who can edit and delete the Universe itself and freely create, edit, or delete
Locations and Characters within that universe. Universes can have an unlimited
number of Users as collaborators who can created, edit, and delete Locations
and Characters within the Universe but cannot change the Universe itself.

#### index

Lists all universes that the currently logged-in user owns or is a collaborator of.

`GET /api/v1/universes/`

sample response:

```
[
  {
    id: 1,
    name: "Milky Way",
    owner: {
      id: 21,
      display_name: "writer21",
    },
  },
  {
    id: 2,
    name: "Max's Cinematic Universe",
    owner: {
      id: 15,
      display_name: "max",
    },
  },
]
```

#### show

Enumerates all properties of the requested Universe, as well as listing all of
its collaborators, characters, and locations. If the current user isn't a
collaborator or owner of the requested universe, a 403 Forbidden error will be
returned.

`GET /api/v1/universes/{universe ID}`

sample response:

```
{
  id: 2,
  name: "Max's Cinematic Universe",
  owner: {
    id: 15,
    display_name: "max",
  },
  collaborators: [
    {
      id: 237,
      display_name: "rip12",
    },
  ],
  characters: [
    {
      id: 1,
      name: "Max",
    },
    {
      id: 4,
      name: "Liese",
    },
    {
      id: 7,
      name: "Scarlet",
    },
  ],
  locations: [
    {
      id: 3,
      name: "Max's Shop",
    },
    {
      id: 9,
      name: "The Ritz Hotel",
    },
    {
      id: 13,
      name: "The Necromancer's Hideout",
    },
  ],
}
```

#### create

`POST /api/v1/universes/`

parameters:

* `name` (required, string): The name of the universe. This name must be unique among all universe.
* `owner_id` (required, integer): The User ID of the User who should own the new universe.
* `collaborator_ids` (required, array of integers): The User ID of all Users who should be collaborators on this universe.

response:

a list of properties of the new Universe (structurally identical to `universe#show`)

#### update

Change a Universe's properties.

`PUT/PATCH /api/v1/universes/{universe ID}`

parameters:

* `name` (optional, string): The new name for this universe.
* `owner_id` (optional, integer): The User ID of the User who should be the new owner of this universe. The current owner will lose ownership if a new User becomes owner.
* `collaborator_ids` (optional, array of integers): The User ID of all Users who should be collaborators on this universe. Note that specifying a collaborator list here will completely overwrite the old collaborators list.

response:

a list of properties of the Universe (structurally identical to `universe#show`)

#### destroy

`DELETE /api/v1/universes/{universe ID}`

Erase a Universe.

response:

HTTP 204 No Content status code with no body

### Locations

Locations are the places of interest inside of a Universe. If the current user
isn't logged in as the owner or a collaborator of the Universe that contains
the Location then an HTTP 403 Forbidden status code will be returned for all
operations on the Location.

#### index

Lists all Locations in the specified Universe.

`GET /api/v1/universes/{universe ID}/locations`

sample response:

```
[
  {
    id: 1,
    name: "Bushy Tail Bar",
  },
  {
    id: 2,
    name: "Lance's Dojo",
  },
  {
    id: 3,
    name: "Modelling Studio",
  },
]
```

#### show

Enumerates all properties of the requested Location.

`GET /api/v1/locations/{location ID}`

sample response:

```
{
  id: 2,
  name: "Lance's Dojo",
  description: "A martial arts school with the logo of a white ferret painted on the door.",
}
```

#### create

Create a new Location within the specified Universe.

`POST /api/v1/universes/{universe id}/locations`

parameters:

* `name` (required, string): The name of the Location. This name must be unique among all Locations in the given Universe.
* `description` (required, string): A text description of the Location.

response:

a list of properties of the new Location (structurally identical to `location#show`)

#### update

Update the properties of a Location.

`PUT/PATCH /api/v1/locations/{location id}`

parameters:

* `name` (optional, string): The new name of the Location. This name must be unique among all Locations in the given Universe.
* `description` (optional, string): A new text description for the Location.

response:

a list of properties of the Location (structurally identical to `location#show`)

#### destroy

Erase a Location.

`DELETE /api/v1/locations/{location id}`

response:

HTTP 204 No Content status code with no body

### Characters

Characters are the people who populate a Universe. If the current user isn't
logged in as the owner or a collaborator of the Universe that contains the
Character then an HTTP 403 Forbidden status code will be returned for all
operations on the Character.

#### index

Lists all Characters in the specified Universe using pagination.

`GET /api/v1/universes/{universe ID}/characters`

parameters:

* `page` (optional, integer): The page of results to return. Defaults to page 1.
* `page_size` (optional, integer): The number of characters per page. Defaults to 100.

sample response:

```
{
  page: 3,
  page_size: 4,
  total_pages: 39,
  characters: [
    {
      id: 1,
      name: "Lance",
    },
    {
      id: 2,
      name: "Kiki",
    },
    {
      id: 3,
      name: "Simon",
    },
    {
      id: 4,
      name: "Saltykov",
    },
  ],
]
```

#### show

Enumerates all properties of the requested Character, including associated
Items, Traits, and images the character has been tagged in.

`GET /api/v1/characters/{character id}`

sample response:

```
{
  id: 2,
  name: "Kiki",
  description: "An athletic fighter. Good with a bow.",
  items: [
    {
      id: 438,
      name: "Bow",
    },
    {
      id: 506,
      name: "Gi",
    },
  ]
  traits: [
    {
      id: 290,
      name: "Determined",
    },
    {
      id: 291,
      name: "Perfectionistic",
    },
  ],
  image_tags: [
    {
      image_tag_id: 546,
      image_id: 27,
      image_caption: "Christmas Party",
      image_url "http://www.example.com/storage/christmas_party.jpg",
    },
    {
      image_tag_id: 549,
      image_id: 20,
      image_caption: "School ID photo",
      image_url "http://www.example.com/storage/kiki_id.jpg",
    },
  ],
}
```

#### create

Create a new Character in the specified Universe.

`POST /api/v1/universes/{universe id}/characters`

parameters:

* `name` (required, string): The name of the Character. This name must be unique among all Characters in the given Universe.
* `description` (required, string): A text description of the Character.

response:

a list of properties of the new Character (structurally identical to `character#show`)

#### update

Update the properties of a Chaaracter.

`PUT/PATCH /api/v1/characters/{character ID}`

parameters:

* `name` (optional, string): The new name of the Character. This name must be unique among all Characters in the given Universe.
* `description` (optional, string): A new text description for the Character.

response:

a list of properties for the new Character (structurally identical to `character#show`)

#### destroy

Erase a Character.

`DELETE /api/v1/characters/{character id}`

response:

HTTP 204 No Content status code with no body

### Character Items

Character Items are items belonging to Characters. If the current user isn't
logged in as the owner or a collaborator of the Universe that contains the
Character then an HTTP 403 Forbidden status code will be returned for all
operations on the Character Item.

#### index

Lists all items belongong to the specified character.

`GET /api/v1/universes/{universe ID}/characters/{character ID}/character_items`

sample response:

```
[
  {
    id: 1,
    name: "Lance",
  },
  {
    id: 2,
    name: "Douchey Shades",
  },
  {
    id: 3,
    name: "Cheap Cologne",
  },
]
```

#### show

Enumerates all properties of the requested Character Item.

`GET /api/v1/character_items/{character item ID}`

sample response:

```
{
  id: 3,
  name: "Cheap Cologne",
}
```

#### create

Add an item to a Character.

`POST /api/v1/universes/{universe ID}/characters/{character ID}/character_items`

parameters:

* `name` (required, string): The item's name.

response:

a list of properties of the new Character Item (structurally identical to `character_item#show`)

#### update

Update the properties of a Character Item.

`PUT/PATCH /api/v1/character_items/{character item ID}`

parameters:

* `name` (optional, string): The new name for the item.

response:

a list of properties for the new Character Item (structurally identical to `character_item#show`)

#### destroy

Remove an item from a Character.

`DELETE /api/v1/character_items/{character item ID}`

response:

HTTP 204 No Content status code with no body

### Character Traits

Character Traits are general traits belonging to Characters. If the current
user isn't logged in as the owner or a collaborator of the Universe that
contains the Character then an HTTP 403 Forbidden status code will be returned
for all operations on the Character Trait.

#### index

Lists all traits belonging to the specified character.

`GET /api/v1/universes/{universe ID}/characters/{character ID}/character_traits`

sample response:

```
[
  {
    id: 1,
    name: "Playful",
  },
  {
    id: 2,
    name: "Meat Lover",
  },
  {
    id: 3,
    name: "Energetic",
  },
]
```

#### show

Enumerates all properties of the requested Character Trait.

`GET /api/v1/character_traits/{character trait ID}`

sample response:

```
{
  id: 3,
  name: "Warm-Hearted",
}
```

#### create

Add a trait to a Character.

`POST /api/v1/universes/{universe ID}/characters/{character ID}/character_traits`

parameters:

* `name` (required, string): The trait's name.

response:

a list of properties of the new Character Trait (structurally identical to `character_trait#show`)

#### update

Change the properties of a Character Trait.

`PUT/PATCH /api/v1/character_traits/{character trait ID}`

parameters:

* `name` (optional, string): The new name for the trait.

response:

a list of properties for the new Character Trait (structurally identical to `character_trait#show`)

#### destroy

Remove a trait from a Character.

`DELETE /api/v1/character_traits/{character trait ID}`

response:

HTTP 204 No Content status code with no body

### Mutual Relationships

Mutual Relationships respresent a relationship between two Characters. Both
Characters in a Mutual Relationship must belong to the same Universe. If the
current user isn't logged in as the owner or a collaborator of the Universe
that contains the Characters then an HTTP 403 Forbidden status code will be
returned for all operations on the Mutual Relationship.

#### index

Lists all relationships emanating out from the specified Character.

`GET /api/v1/universes/{universe ID}/characters/{character ID}/mutual_relationships`

sample response:

```
[
  {
    id: 1,
    name: "Bodyguard",
    target_character: {
      id: 2,
      name: "Grace",
    },
  },
  {
    id: 2,
    name: "Husbaaand",
    target_character: {
      id: 2,
      name: "Grace",
    },
  },
  {
    id: 3,
    name: "Father",
    target_character: {
      id: 3,
      name: "Hope",
    },
  },
  {
    id: 4,
    name: "Father",
    target_character: {
      id: 4,
      name: "Joy",
    },
  },
  {
    id: 5,
    name: "Boss",
    target_character: {
      id: 5,
      name: "Ripose",
    },
  },
]
```

#### show

Enumerates all properties of the requested Mutual Relationship.

`GET /api/v1/mutual_relationships/{mutual relationship ID}`

sample response:

```
{
  id: 3,
  forward_name: "Father",
  reverse_name: "Daughter",
  character1: {
    id: 1,
    name: "Kayin",
  },
  character2: {
    id: 3,
    name: "Hope",
  },
}
```

#### create

Add a relationship between two Characters.

`POST /api/v1/universes/{universe ID}/characters/{originatng character ID}/mutual_relationships`

parameters:

* `forward_name` (required, string): The name for the relationship going from the orignating character to the target character.
* `reverse_name` (required, string): The name for the relationship going from the target character to the originating character.
* `target_character_id` (required, integer): The ID of the second character in the relationship.

response:

a list of properties of the new Mutual Relationship (structurally identical to `mutual_relationship#show`)

#### update

Change the properties of a Mutual Relationship.

`PUT/PATCH /api/v1/mutual_relationships/{mutual relationship ID}`

parameters:

* `originating_character_id` (required, integer): The ID of the character in the relationship that should be considered the originating character for the purpose of the forward and reverse direction names in the other parameters.
* `forward_name` (optional, string): The new name for the relationship going from the orignating character to the target character.
* `reverse_name` (optional, string): The new name for the relationship going from the target character to the originating character.

response:

a list of properties for the new Mutual Relationship (structurally identical to `mutual_relationships#show`)

#### destroy

Erase a relationship.

`DELETE /api/v1/mutual_relationships/{mutual relationship ID}`

response:

HTTP 204 No Content status code with no body

### Images

Images are image files uploaded to the Black Book. Once an Image is created,
characters in the image can be tagged using the ImageTag model below.

#### show

Enumerates all properties of the requested Image and lists all characters that
have been tagged in the Image. The characters shown are restricted to only
characters in universes the current user has access to--tagged characters in
universes not visible to the current user aren't shown.

`GET /api/v1/images/{image ID}`

sample response:

```
{
  id: 2,
  caption: "Christmas Party",
  image_url: "http://example.com/storage/christmas_party.jpg",
  characters: [
    { id: 34, name: "B.A. Baracus" },
    { id: 35, name: "John Smith" },
    { id: 36, name: "Templeton Pec" },
    { id: 37, name: "H.M. Murdock" },
  ],
}
```

#### create

Create a new Image by uploading an image file and optionally providing a
caption.

`POST /api/v1/images/`

parameters:

* `image_file` (required, file): The image file.
* `caption` (optional, string): A caption for the image.

response:

a list of properties of the new Image (structurally identical to `images#show`)

#### update

Change the caption of an Image.

`PUT/PATCH /api/v1/images/{image ID}`

parameters:

* `caption` (required, string): The new caption for the Image.

response:

a list of updated properties for the Image (structurally identical to `image#show`)

#### destroy

Delete a stored Image.

`DELETE /api/v1/images/{image ID}`

response:

HTTP 204 No Content status code with no body

### Image Tag

Tag characters in an Image.

#### show

Enumerates all properties of the requested ImageTag. If the current user isn't
a collaborator or owner of the universe the tagged character belongs to, then a
403 Forbidden error will be returned.

`GET /api/v1/image_tags/{image tag ID}`

sample response:

```
{
  id: 5,
  character: { id: 6, name: "Buck Firestone" },
  image: { id: 1, url: "http://example.com/storage/sky.png" },
}
```

#### create

Tag a character in an image. If the current user isn't a collaborator or owner
of the universe the tagged character belongs to, then a 403 Forbidden error
will be returned and the ImageTag won't be created.

`POST /api/v1/images/{image ID}/image_tags`

parameters:

* `character_id` (required, integer): the ID of the character to tag in the image.

response:

a list of properties of the new ImageTag (structurally identical to `image_tags#show`)

#### destroy

Remove a character tagging from an image. If the current user isn't a
collaborator or owner of the universe the tagged character belongs to, then a
403 Forbidden error will be returned and the ImageTag won't be deleted.

`DELETE /api/v1/image_tags/{image tag ID}`

response:

HTTP 204 No Content status code with no body

### Search

The Search API allows fuzzy text searching across models within a single
universe. It returns a mix of any Character and Location models that match the
given search terms. It also returns Character models whose Relationships,
Items, or Traits match the given search terms.

`GET /api/v1/universes/{universe ID}/search`

parameters:

* `terms` (required, string): the text to search for

sample response:

```
[
  {
    id: 1,              # the model ID
    type: "Character",  # the model's class
    name: "Arturo",     # the name field for the model
    highlights: [       # an array containing the parts of the model that matched the search query
      "<strong>Arturo</strong>",
      "<strong>Adventurer's Kit</strong>",  # includes items attached to the character
      "<strong>Adventurous</strong>",       # includes traits attached to the character
    ],
  },
  {
    id: 2,
    type: "Location",
    name: "Adventurer's Guild",
    highlights: [
      "Adventurer's Guild",
    ],
  },
]
```
