# Blackbook

Track everything about your fictional universes with ease.  

## Usage
The Blackbook allows users to remember a high amount of detail about their fantasy settings while also remaining organized.  

### Universe
Users own multiple universes. Each universe is tied to an intellectual property that you are creating. They are containers for the chartacters, locations, items, and images for your setting.  

ie. `Redwall` would be a universe.  

### Characters
A character is the primary entity that the blackbook was designed to track. Characters will always have a name and description, yet can have any number of optional relationships, traits, items and images assigned to them.  

ie. `Martin the Warrior` would be a character in the `Redwall` universe.  

#### Character Traits
A character trait is an arbitrary piece of descriptive data about a character. The blackbook doesn't assume a character will have anything descriptive besides a name. So all facts about a character you would like to remember are traits.  

ie. `Brave` could be a character trait of `Martin the Warrior`, describing the character's personality.  
ie. `Book: Mossflower` could be a character trait of `Martin the Warrior`, describing an appearance.  

#### Character Items
A character item is any item that a character has in their posession that you would like to track.  

ie. `Sword of Martin` would be a character item of `Martin the Warrior`.  

#### Character Relationship
A character will likely have many relationships within your setting. You can track them all in a bi-drectional manner in Blackbook. When creating a relationship, you need to specify the name of the relationship in both directions. A relationship cannot be one-way. If either side of the relationship is deleted, the entire thing is deleted.  

ie. `Martin the Warrior` would be listed as `Son` to `Luke the Warrior`.  
ie. `Luke the Warrior` would be listed as `Father` to `Martin the Warrior`.   

### Images
A universe can have any number of images in it and can be browsed in the universe. Images become much more useful when coupled with Image Tags. Image Tags are used to describe which characters from the universe are present in the image. Then that image will be displayed in each relevant character entry.  

ie. `Martin the Warrior` would be a tagged in [this image](https://upload.wikimedia.org/wikipedia/en/thumb/c/c7/MartinTheWarriorUK.jpg/220px-MartinTheWarriorUK.jpg). And the image would appear in the `Martin the Warrior` character page.  

### Locations
A location currently just supports a name and a description with more features planned for future releases.  

## Development
`rails s` -> `localhost:3000`  

Expected Ruby Version: `3.00`  

License: AGPLv3+  
