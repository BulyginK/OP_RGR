PROGRAM CountWords(INPUT, OUTPUT);
USES ReadWords, TreeSort;
VAR
  InFile, OutFile: TEXT;
  Word: STRING;

BEGIN
  ASSIGN(InFile, 'Text.txt');
  RESET(InFile);
  ASSIGN(OutFile, 'CountWords.txt');
  REWRITE(OutFile);
  WHILE NOT EOF(InFile)
  DO
    BEGIN
      Word := ReadWord(InFile);
      InsertStorage(Word, InFile)
    END;
  PrintStorage(OutFile)
END.
