UNIT ReadWords;

INTERFACE
  VAR
    Word: STRING;

  CONST
    FirstWordLess = 1;
    SecondWordLess = 2;
    WordsEqual = 0;

  FUNCTION ReadWord(VAR Text: TEXT): STRING;
  FUNCTION GetLessWord(Word1, Word2: STRING): INTEGER;
  
IMPLEMENTATION
CONST
  StrUper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅ¨ÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞß';
  StrLow =  'abcdefghijklmnopqrstuvwxyzàáâãäå¸æçèéêëìíîïðñòóôõö÷øùúûüýþÿ';

FUNCTION ReadWord(VAR Text: TEXT): STRING;
CONST
  Hyphen = '-';

VAR
  Ch: CHAR;
  EndWord, FoundWord: BOOLEAN;
  
FUNCTION StrUperToLow(Ch: CHAR): CHAR;
BEGIN
  IF pos(Ch, StrUper) > 0
  THEN
    StrUperToLow := StrLow[pos(Ch, StrUper)]
  ELSE
    StrUperToLow := Ch  
END; 
  
BEGIN
  Word := '';
  FoundWord := FALSE;
  EndWord := FALSE;
  WHILE NOT EOF(Text) AND NOT EOLN(Text) AND NOT EndWord
  DO
    BEGIN
      READ(Text, Ch);
      IF Ch <> Hyphen
      THEN
        IF ((pos(Ch, StrUper) > 0) OR (pos(Ch, StrLow) > 0))
        THEN
          BEGIN
            FoundWord := TRUE;
            Word := Word + StrUperToLow(Ch)
          END
        ELSE
          EndWord := TRUE
      ELSE
        BEGIN
          IF FoundWord AND EOLN(Text)
          THEN 
            READLN(Text);
          IF FoundWord AND NOT EOLN(Text)
          THEN 
            Word := Word + Hyphen
        END
    END;
  IF Word[length(Word)] = Hyphen
  THEN
    DELETE(Word, length(Word), 1);       
  IF EOLN(Text)
  THEN
    READLN(Text);
  ReadWord := Word
END;

FUNCTION GetLessWord(Word1, Word2: STRING): INTEGER;
VAR
  Sort, I: INTEGER;
  LenWord1, LenWord2: INTEGER;
BEGIN
  I := 1;
  Sort := WordsEqual;
  LenWord1 := length(Word1);
  LenWord2 := length(Word2);
  WHILE (Sort = WordsEqual) AND (I <= LenWord1) AND (I <= LenWord2) 
  DO
    BEGIN
      IF (pos(Word1[I], StrLow)) < (pos(Word2[I], StrLow))
      THEN
        Sort := FirstWordLess;
      IF (pos(Word1[I], StrLow)) > (pos(Word2[I], StrLow))
      THEN
        Sort := SecondWordLess;
      I := I + 1  
    END;
  IF (Sort = WordsEqual) AND (LenWord1 <> LenWord2)
  THEN
    IF (LenWord1 < LenWord2)
    THEN
      Sort := FirstWordLess
    ELSE
      Sort := SecondWordLess;
  GetLessWord := Sort
END;

BEGIN
END.
