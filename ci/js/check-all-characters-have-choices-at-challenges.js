const fs = require("fs");

const CHARACTER_FILE_PATH = "./data/characters.json";
const CHALLENGE_FILE_PATH = "./data/challenges.json";
const EXIT_CODE_ERROR = 1;

/**
 * Validates the character can beat the challenge with the given choice.
 * @param {object} character - The character data.
 * @param {object} challenge - The challenge data.
 * @param {object} choice - The choice data.
 * @returns {boolean} True if valid, false otherwise.
 */
function validateCharacterStartingPossessionsCanBeatChoice(
  character,
  challenge,
  choice,
) {
  const startingPossessions = character.starting_possessions;
  const requirements = choice.requirements;
  const costs = choice.costs;
  for (const requirement of requirements) {
    const requiredPossession = requirement.possession;
    const requiredCount = requirement.count;
    const startingCount = startingPossessions[requiredPossession] ?? 0;
    if (startingCount < requiredCount) {
      // console.log(
      //   "\t\t\t\t\t",
      //   "validateCharacterStartingPossessionsCanBeatChoice",
      //   "validating",
      //   "character",
      //   character.name,
      //   "challenge",
      //   challenge.name,
      //   "requiredPossession",
      //   requiredPossession,
      //   "startingCount",
      //   startingCount,
      //   "[less than]",
      //   "requiredCount",
      //   requiredCount,
      // );
      return false;
    }
  }
  for (const cost of costs) {
    const costPossession = cost.possession;
    const costCount = cost.count;
    const startingCount = startingPossessions[costPossession] ?? 0;
    if (startingCount < costCount) {
      // console.log(
      //   "validateCharacterStartingPossessionsCanBeatChoice",
      //   "validating",
      //   "character",
      //   character.name,
      //   "challenge",
      //   challenge.name,
      //   "costPossession",
      //   costPossession,
      //   "startingCount",
      //   startingCount,
      //   "[less than]",
      //   "costCount",
      //   costCount,
      // );
      return false;
    }
  }
  const json = {
    character: character.name,
    challenge: challenge.name,
    choice: choice.name,
    starting_possessions: Object.keys(startingPossessions).sort(),
  };
  // console.log(
  //   // "\t\t\t\t\t",
  //   "validateCharacterStartingPossessionsCanBeatChoice",
  //   "valid",
  //   json,
  // );
  return true;
}

/**
 * Validates the character and challenge data.
 * @param {object} character - The character data.
 * @param {object} challenge - The challenge data.
 * @returns {boolean} True if valid, false otherwise.
 */
function validateCharacterChallenge(character, challenge) {
  // console.log(
  //   "\t\t\t",
  //   "validateCharacterChallenge",
  //   "validating",
  //   "character",
  //   character.name,
  //   "challenge",
  //   challenge.name,
  // );
  let anyChoiceBeatsChallenge = false;
  let choiceThatBeatsChallenge;
  for (const choice of challenge.json_data.choices) {
    // console.log(
    //   "\t\t\t\t",
    //   "validateCharacterChallenge",
    //   "validating",
    //   "character",
    //   character.name,
    //   "challenge",
    //   challenge.name,
    //   "choice",
    //   choice.name,
    //   "requirements",
    //   choice.requirements,
    //   "costs",
    //   choice.costs,
    // );
    if (
      validateCharacterStartingPossessionsCanBeatChoice(
        character,
        challenge,
        choice,
      )
    ) {
      choiceThatBeatsChallenge = choice;
      anyChoiceBeatsChallenge = true;
    }
  }
  if (!anyChoiceBeatsChallenge) {
    console.log(
      "validateCharacterChallenge",
      "❌ failure",
      "character",
      character.name,
      "challenge",
      challenge.name,
      "starting_possessions",
      character.starting_possessions,
      "for this character, no choice beats the challenge with starting posessions",
    );
    return false;
  }
  // console.log(
  //   "validateCharacterChallenge",
  //   "✅ success",
  //   "character",
  //   character.name,
  //   "challenge",
  //   challenge.name,
  //   "choiceThatBeatsChallenge",
  //   choiceThatBeatsChallenge.name,
  //   "starting_possessions",
  //   character.starting_possessions,
  // );
  return true;
}

/**
 * Validates the character and challenge data arrays.
 * @param {object} characterData - The character data array.
 * @param {object} challengeData - The challenge data array.
 * @returns {boolean} True if valid, false otherwise.
 */
function validateCharacterChallengeData(characterData, challengeData) {
  for (const character of characterData) {
    // console.log(
    //   // "\t",
    //   "validateCharacterChallengeData",
    //   "validating",
    //   "character",
    //   character.name,
    // );
    for (const challenge of challengeData) {
      // console.log(
      //   "\t\t",
      //   "validateCharacterChallengeData",
      //   "validating",
      //   "character",
      //   character.name,
      //   "challenge",
      //   challenge.name,
      // );
      if (!validateCharacterChallenge(character, challenge)) {
        return false;
      }
    }
  }
  return true;
}

function run() {
  try {
    const allCharacterData = JSON.parse(
      fs.readFileSync(CHARACTER_FILE_PATH, "utf8"),
    );
    const characterData = [];
    for (const character of allCharacterData) {
      if (character.active) {
        characterData.push(character);
      }
    }
    const allChallengeData = JSON.parse(
      fs.readFileSync(CHALLENGE_FILE_PATH, "utf8"),
    );
    const challengeData = [];
    for (const challenge of allChallengeData) {
      if (challenge.active) {
        if (challenge.json !== undefined) {
          const jsonPath = challenge.json.replace("res://", "./");
          challenge.json_data = JSON.parse(fs.readFileSync(jsonPath, "utf8"));
          challengeData.push(challenge);
        }
      }
    }

    // console.log("characterData", characterData.sort());

    if (validateCharacterChallengeData(characterData, challengeData)) {
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
