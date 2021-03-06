shared_context "a Celluloid Mailbox" do
  it "receives messages" do
    message = :ohai

    subject << message
    subject.receive.should == message
  end

  it "prioritizes system events over other messages" do
    subject << :dummy1
    subject << :dummy2

    subject << Celluloid::SystemEvent.new
    subject.receive.should be_a(Celluloid::SystemEvent)
  end

  it "selectively receives messages with a block" do
    class Foo; end
    class Bar; end
    class Baz; end

    foo, bar, baz = Foo.new, Bar.new, Baz.new

    subject << baz
    subject << foo
    subject << bar

    subject.receive { |msg| msg.is_a? Foo }.should eq(foo)
    subject.receive { |msg| msg.is_a? Bar }.should eq(bar)
    subject.receive.should eq(baz)
  end

  it "waits for a given timeout interval" do
    interval = 0.1
    started_at = Time.now

    subject.receive(interval) { false }
    (Time.now - started_at).should be_within(Celluloid::TIMER_QUANTUM).of interval
  end

  it "has a size" do
    subject.should respond_to(:size)
    subject.size.should be_zero
    subject << :foo
    subject << :foo
    subject.size.should be 2
  end
end
