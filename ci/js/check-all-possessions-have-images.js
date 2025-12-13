const fs = require("fs");

const CHARACTER_FILE_PATH = "./data/characters.json";
const POSSESSIONS_FILE_PATH = "./data/possessions.json";
const EXIT_CODE_ERROR = 1;

/**
 * Validates the possession data array.
 * @param {object} possessionData - The possession data array.
 * @param {object} characterPossessionsSet - The character possession set.
 * @returns {boolean} True if valid, false otherwise.
 */
function validatePossessionsImages(possessionData, characterPossessionsSet) {
  var possessionDataIsValid = true;
  const imagePossessionSet = new Set();
  for (const possession of possessionData) {
    const imagePath = possession.texture.replace("res://", "./");
    if (fs.existsSync(imagePath)) {
      imagePossessionSet.add(possession.name);
    } else {
      console.log("❌ Failure!.", "missing image with path", [imagePath]);
      possessionDataIsValid = false;
    }
  }
  for (const possession of characterPossessionsSet) {
    // Check if the item is NOT present in the image set
    if (!imagePossessionSet.has(possession)) {
      console.log("❌ Failure!.", "missing image with name", [possession]);
      possessionDataIsValid = false;
    }
  }
  return possessionDataIsValid;
}

function run() {
  try {
    const characterData = JSON.parse(
      fs.readFileSync(CHARACTER_FILE_PATH, "utf8"),
    );
    const characterPossessions = new Set();
    for (const character of characterData) {
      const startingPossessions = character.starting_possessions;
      for (const possession in startingPossessions) {
        characterPossessions.add(possession);
      }
      const desiredPossessions = character.desired_possessions;
      for (const possession in desiredPossessions) {
        characterPossessions.add(possession);
      }
    }

    const possessionData = JSON.parse(
      fs.readFileSync(POSSESSIONS_FILE_PATH, "utf8"),
    );

    // console.log("characterPossessions", [...characterPossessions].sort());
    // console.log("possessionData", possessionData.sort());

    if (validatePossessionsImages(possessionData, characterPossessions)) {
      console.log("✅ Success!.");
    } else {
      console.log("❌ Failure!.");
      // Validation failed, set error exit code
      process.exitCode = EXIT_CODE_ERROR;
    }
  } catch (error) {
    console.error(
      `🛑 FATAL Error processing characters and challenges:`,
      error,
    );
    process.exitCode = EXIT_CODE_ERROR;
  }
}
run();
