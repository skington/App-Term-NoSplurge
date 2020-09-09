#!/usr/bin/env perl
# An overly-effusive script that spits out far too much stuff,
# without even the passing courtesy of adding linefeeds.

use strict;
use warnings;

# For legibility, here's the spam sketch *with* line feeds in.
my $spam_with_linefeeds = <<SPAM;
Scene: A cafe. One table is occupied by a group of Vikings with horned helmets
on. A man and his wife enter.

Man (Eric Idle): You sit here, dear.

Wife (Graham Chapman in drag): All right.

Man (to Waitress): Morning!

Waitress (Terry Jones, in drag as a bit of a rat-bag): Morning!

Man: Well, what've you got?

Waitress: Well, there's egg and bacon; egg sausage and bacon; egg and spam; egg
bacon and spam; egg bacon sausage and spam; spam bacon sausage and spam; spam
egg spam spam bacon and spam; spam sausage spam spam bacon spam tomato and spam;

Vikings (starting to chant): Spam spam spam spam...

Waitress: ...spam spam spam egg and spam; spam spam spam spam spam spam baked
beans spam spam spam...

Vikings (singing): Spam! Lovely spam! Lovely spam!

Waitress: ...or Lobster Thermidor aux Crevettes with a Mornay sauce served in a
Provencale manner with shallots and aubergines garnished with truffle pate,
brandy and with a fried egg on top and spam.

Wife: Have you got anything without spam?

Waitress: Well, there's spam egg sausage and spam, that's not got much spam in
it.

Wife: I don't want ANY spam!

Man: Why can't she have egg bacon spam and sausage?

Wife: THAT'S got spam in it!

Man: Hasn't got as much spam in it as spam egg sausage and spam, has it?

Vikings: Spam spam spam spam (crescendo through next few lines)

Wife: Could you do the egg bacon spam and sausage without the spam then?

Waitress: Urgghh!

Wife: What do you mean 'Urgghh'? I don't like spam!

Vikings: Lovely spam! Wonderful spam!

Waitress: Shut up!

Vikings: Lovely spam! Wonderful spam!

Waitress: Shut up! (Vikings stop) Bloody Vikings! You can't have egg bacon spam
and sausage without the spam.

Wife (shrieks): I don't like spam!

Man: Sshh, dear, don't cause a fuss. I'll have your spam. I love it. I'm having
spam spam spam spam spam spam spam beaked beans spam spam spam and spam!

Vikings (singing): Spam spam spam spam. Lovely spam! Wonderful spam!

Waitress: Shut up!! Baked beans are off.

Man: Well could I have her spam instead of the baked beans then?

Waitress: You mean spam spam spam spam spam spam... (but it is too late and the
Vikings drown her words)

Vikings (singing elaborately): Spam spam spam spam. Lovely spam! Wonderful
spam! Spam spa-a-a-a-a-am spam spa-a-a-a-a-am spam. Lovely spam! Lovely spam!
Lovely spam! Lovely spam! Lovely spam! Spam spam spam spam!SPAM

SPAM

# Now turn paragraph breaks into line-feeds, and remove all other line-feeds.
my $spam_without_linefeeds = $spam_with_linefeeds;
$spam_without_linefeeds =~ s{ \n\n }{<PARA>}gxsm;
$spam_without_linefeeds =~ s{ \n }{}gxsm;
$spam_without_linefeeds =~ s{<PARA>}{\n}gsm;

# Now print that out.
print $spam_without_linefeeds;
